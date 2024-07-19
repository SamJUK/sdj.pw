---
title: "Comparing Magento 2 DB Schema Changes"
description: "Generate a diff report for the difference between the Magento 2 DB Schema in code, and the schema currently deployed."
date: 2023-11-12T11:30:00+00:00
tags: ["magento2", "debugging"]
author: "Me"
draft: false
---
Recently I came across an issue on a site where the `setup:db:status` would constantly report `Declarative Schema is not up to date` even after consecutive runs. This was breaking the zero downtime deployment configuration for the store, as the CD process always saw DB updates to process.

There seemed to be (at least at the time of writing) very little information / tooling on how to debug db schema issues. So after a bunch of reverse engineering Magento's implementation of DB Schema, I ended up creating a simple script that compares the current DB schema with the current configuration in the compiled `db_schema.xml`.

The script that I created gave us the following output, which allowed me to attribute the bug to the Amasty Rewards module. And after a quick support ticket, we was able to get this resolved in a timely manner.
```
Table ID: 409
  Operation: add_column
    NEW:
      - Name: expiration_id
      - Type: int
      - ElementType: column
      - TableName: amasty_rewards_rewards
```

## The Script

To use the script, you can place the following code in a PHP file within the Magento root (where the composer files are located). Then you can run the file name with CLI php.

I like to prefix the files with `z_` to easily distinguish between core Magento files and temporary scripts that need to be cleaned up.

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
