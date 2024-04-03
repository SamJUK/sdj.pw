---
title: "Magento 2 DB Schema Diff"
date: 2023-11-12T11:30:00+00:00
tags: ["magento2", "db_schema", "debugging"]
author: "Me"
draft: false
---
Recently I came across an issue on a site where the `setup:db:status` would constantly report `Declarative Schema is not up to date` even after consecutive runs. Which was breaking the zero downtime deployments configured for the store. 

In our case by using the script below we got the following output. Which we was able to attribute to error to the Amasty Rewards module, which was deferred to Amasty to resolve.
```
Table ID: 409
  Operation: add_column
    NEW:
      - Name: expiration_id
      - Type: int
      - ElementType: column
      - TableName: amasty_rewards_rewards
```

After some reverse engineering of the DB Schema code, I came up with the following script that can be placed at the Magento root. It will give us all the DB changes that the system thinks are happening.
```php
<?php
#
# Lists the differences between the currently installed Schema and that parsed from db_schema.xml
#


use Magento\Framework\App\Bootstrap, Magento\Catalog\Model\ResourceModel\Product\CollectionFactory;

require __DIR__ . '/app/bootstrap.php';
error_reporting(E_ALL & ~E_NOTICE);
$bootstrap = Bootstrap::create(BP, $_SERVER);
$obj = $bootstrap->getObjectManager();

$sd = $obj->get(\Magento\Framework\Setup\Declaration\Schema\Diff\SchemaDiff::class);
$sc = $obj->get(\Magento\Framework\Setup\Declaration\Schema\SchemaConfigInterface::class);

$dbSchema = $sc->getDbConfig();
$declarativeSchema = $sc->getDeclarationConfig();

$diff = $sd->diff($declarativeSchema, $dbSchema);
$changes = $diff->getAll();

foreach ($changes as $tableIndex => $operations) {
    echo "Table Index: $tableIndex", PHP_EOL;
    
    foreach ($operations as $operation => $data) {
        echo "  Operation: $operation", PHP_EOL;

        foreach ($data as $k => $history) {
            $oldDto = $history->getOld();
            $newDto = $history->getNew();

            if ($oldDto) {
                echo "    Old DtoObject:", PHP_EOL;
                echo "      - Name: {$oldDto->getName()}", PHP_EOL;
                echo "      - Type: {$oldDto->getType()}", PHP_EOL;
                echo "      - ElementType: {$oldDto->getElementType()}", PHP_EOL;
                
                if ($oldDto->getTable() && $oldDto->getTable()->getName()) {
                    echo "      - TableName: {$oldDto->getTable()->getName()}", PHP_EOL;
                }
            }

            if ($newDto) {
                echo "    New DtoObject:", PHP_EOL;
                echo "      - Name: {$newDto->getName()}", PHP_EOL;
                echo "      - Type: {$newDto->getType()}", PHP_EOL;
                echo "      - ElementType: {$newDto->getElementType()}", PHP_EOL;
                
                if ($newDto->getTable() && $newDto->getTable()->getName()) {
                    echo "      - TableName: {$newDto->getTable()->getName()}", PHP_EOL;
                }
            }
        }
    }
}
```