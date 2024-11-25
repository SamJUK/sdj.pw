---
title: "Adobe Commerce - Improved Magento Vars Store Code Configuration"
description: "A simplified version of the magento-vars.php store code configuration. That catches both CNAME alias' and dynamic integration urls"
date: 2024-04-29T19:00:00+00:00
tags: ["magento2", "adobe-commerce", "magento-cloud"]
author: "Me"
draft: false
documentation: https://docs.sdj.pw/magento/cloud-store-codes.html
---
The default `magento-vars.php` file that is referenced through the Adobe Commerce documentation leaves a lot to be desired and can become a pain when managing stores with many websites and store views.
Luckily we can simplify this configuration using the `match` implementation within PHP8. 

This version of the script allows us to configure new store fronts by adding a single case to the match statement.

```php
<?php
$host = $_SERVER['HTTP_HOST'] ?? '';
$ephemeralHostScope = fn(string $host): ?string => substr_count($host, '.') === 4 ? strtok($host, '.') : null;

$_SERVER["MAGE_RUN_TYPE"] = 'store';
$_SERVER["MAGE_RUN_CODE"] = match(true) {
    $ephemeralHostScope($host) === 'us' || str_contains($host, 'example.com') => 'us',
    $ephemeralHostScope($host) === 'gb' || str_contains($host, 'example.co.uk') => 'gb',
    $ephemeralHostScope($host) === 'cn' || str_contains($host, 'example.cn') => 'cn',
    default => 'base'
};
```

We are targeting two URL formats within this upgrade script. 
1. Custom CNAMES records that point to `prod.magentocloud.map.fastly.net` (e.g staging.example.com)
2. Adobe Cloud dynamic urls usually in the format of `https://<store>.<integration_env>.<region>.magentosite.cloud`

