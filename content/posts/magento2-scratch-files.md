---
title: "Magento 2 Scratch Files"
date: 2023-02-17T11:30:00+00:00
tags: ["magento"]
author: "Me"
draft: false
categories:
  - magento
---
I often find the need to test components / functionality independently of the system or execute single time use scripts. Which i find developing and deploying a whole module is a waste of time and resources.

Some recent uses of scratch files are: 
- Inspecting product or category data to help debug data issues
- Inspecting Cached Data
- Bulk assigning attributes
- Bulk renaming SKUs etc

This is where scratch files come in handy, we can create a simple PHP file in the Magento root (I tend to prefix with `z_` to easily find them). Then by using the following code at the top of the file, we can use object manager to instantiate/fetch classes to perform whatever operation we need. 

```php
<?php

use Magento\Framework\App\Bootstrap;
require __DIR__ . '/app/bootstrap.php';
error_reporting(E_ALL & ~E_NOTICE);
$bootstrap = Bootstrap::create(BP, $_SERVER);
$obj = $bootstrap->getObjectManager();

// $state = $obj->get('Magento\Framework\App\State');
// $state->setAreaCode('adminhtml');
```

I keep this code in a [Alfred snippet](https://www.alfredapp.com/help/features/snippets/), which allows me to easily paste this text both in my IDE and vim terminal instances.