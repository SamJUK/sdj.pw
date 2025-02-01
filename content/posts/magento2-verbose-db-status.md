---
title: "Verbose Magento 2 DB Schema Status"
description: "Ever found yourself wondering why a store required downtime to deploy? Or even the case where `setup:db:status` constantly reports `Declarative Schema is not up to date` despite you just update it? "
date: 2025-02-03T05:00:00+00:00
tags: ["magento2", "devops", "debugging", "deployment"]
author: "Me"
draft: false
documentation: https://docs.sdj.pw/magento/identify-db-schema-changes.html
---

Terraform offers the `-plan` flag and Ansible offers the `--check` flag. But what does Magentos DB Schema offer?

It can be very frustrating, when you have unexpected schema changes occur. And as far as I can tell, there is no core way to visualise the changes.

Last year I wrote about the time I had this exact issue, and how I went about identify what DB schema was trying todo. You can read that here, but the script is out of date now: [http://www.sdj.pw/posts/magento2-db-schema-diff/](http://www.sdj.pw/posts/magento2-db-schema-diff/)


## Magento 2 Module

I recently converted the script into a module. It extends the core `setup:db:status` command and offers new functionality in the way of `-v` and `-vv` flags.

The idea behind the module form factor, is mostly around use in a CI pipeline. You can use a combination of the exit code of the command and verbose output on your staging environment, to decorate a PR/Workflow summary to identify if downtime will be required for a production deploy & what changes will occur.

The source code can be found on my Github over at [SamJUK/m2-module-verbose-db-status](https://github.com/SamJUK/m2-module-verbose-db-status/).

## Scratch File

The quick and dirty solution, write a PHP file to the root of your installation, run it with the PHP CLI and your done.  The maintained version of the script can be found over on my [documentation site](https://docs.sdj.pw/magento/identify-db-schema-changes.html#script)

```php
<?php
/**
 * Identify DB Schema differences in current (db) and target (xml files) state.
 *
 * Usage:
 *  php ./z_identify_db_schema_diff.php [-v|--verbose]
 */

use Magento\Framework\App\Bootstrap;
require __DIR__ . '/app/bootstrap.php';
error_reporting(E_ALL & ~E_NOTICE);
$bootstrap = Bootstrap::create(BP, $_SERVER);
$obj = $bootstrap->getObjectManager();

const INDENT_TARGET = 4;
const INDENT_CHANGE = 8;

$isVerbose = count(array_filter($argv, static function($param) {
    return in_array($param, ['-v', '--verbose']);
})) > 0;

$schemaDiff = $obj->get('\Magento\Framework\Setup\Declaration\Schema\Diff\SchemaDiff');
$schemaConfig = $obj->get('\Magento\Framework\Setup\Declaration\Schema\SchemaConfigInterface');

$changes = $schemaDiff->diff(
    $schemaConfig->getDeclarationConfig(),
    $schemaConfig->getDbConfig()
)->debugChanges;

if (!$changes) {
    echo "Schema is up to date!", PHP_EOL;
    exit(0);
}

foreach ($changes as $operation => $targets) {
    echo "$operation: ", PHP_EOL;

    foreach ($targets as $target) {
        $oldData = extractData($target->getOld());
        $newData = extractData($target->getNew());
        $title = sprintf(
            '%s (%s)',
            $newData['name'],
            trim(implode(' ', [
            $newData['type'],
            $newData['element_type'],
            $newData['table']
            ]))
        );

        echo str_repeat(' ', INDENT_TARGET) . "Target: $title", PHP_EOL;

        foreach($newData as $k => $v) {
            if (!array_key_exists($k, $oldData) || $oldData[$k] !== $v) {
            echo sprintf(
                '%s%s: %s -> %s' . PHP_EOL,
                str_repeat(' ', INDENT_CHANGE),
                $k,
                str_replace("\n", " ", var_export(@$oldData[$k], true)),
                str_replace("\n", " ", var_export(@$newData[$k], true))
            );
            }
        }

        if ($isVerbose) {
            [$oldData, $newData] = shakeMutualData($oldData, $newData);
            echo sprintf(
            '%s%s: %s -> %s' . PHP_EOL,
            str_repeat(' ', INDENT_CHANGE),
            'data',
            json_encode($oldData),
            json_encode($newData)
            );
        }
    }
}

function shakeMutualData($oldData, $newData)
{
    $combinedKeys = array_unique([
        ...array_keys($oldData),
        ...array_keys($newData)
    ]);

    $diffKeys = array_filter(
        $combinedKeys,
        function ($k) use ($oldData, $newData) {
        return !(array_key_exists($k, $oldData)
            && array_key_exists($k, $newData)
            && $oldData[$k] === $newData[$k]);
        }
    );

    $filterCallback = static function ($k) use ($diffKeys) {
        return in_array($k, $diffKeys, true);
    };

    return [
        array_filter($oldData, $filterCallback, ARRAY_FILTER_USE_KEY),
        array_filter($newData, $filterCallback, ARRAY_FILTER_USE_KEY),
    ];
}

function extractData(?\Magento\Framework\Setup\Declaration\Schema\Dto\ElementInterface $element): array
{
    if ($element == null) {
        return [];
    }

    $params = $element instanceof \Magento\Framework\Setup\Declaration\Schema\Dto\ElementDiffAwareInterface ? $element->getDiffSensitiveParams() : [];
    $params['name'] = $element->getName();
    $params['type'] = $element->getType();
    $params['element_type'] = $element->getElementType();
    $params['table'] = $element instanceof \Magento\Framework\Setup\Declaration\Schema\Dto\TableElementInterface ? $element->getTable()->getName() : '';
    return $params;
}
```


## N98 Module

There is a variant of the script within a N98 module I maintain, currently the module is not publicly available. Although I am in the process of updating the module to be open source over at [SamJUK/n98-module-samjuk](https://github.com/SamJUK/n98-module-samjuk)
