---
title: "Magento 2 - Fix Missing Products & Search After Upgrading to Elasticsearch 8"
description: "After upgrading Magento 2 to Elasticsearch 8 and your products disappeared or search broke? This short post walks through the fixes to get your store working again in minutes."
date: 2024-04-24T19:00:00+00:00
tags: ["magento2", "elasticsearch"]
author: "Me"
draft: false
---
## What this guide fixes

If, after upgrading Magento 2.4.6+ to use Elasticsearch 8, your **product catalog pages show zero products or your search is broken**, this post walks through the configuration steps required to fix it - including reindexing, enabling the right modules, and updating Elasticsearch settings.

This page is for developers and sysadmins who already maintain a Magento 2 store and need a quick, practical fix for Elasticsearch 8 compatibility issues.

## TL;DR
If products disappear from category pages or search results after upgrading Magento 2 to Elasticsearch 8:

- Ensure your indexes and cache are up to date
- Double check your Magento search config (the keys are different from Elasticsearch7!)
- Make sure the Elasticsearch8 module is installed, for some reason its not included by default
- Enable support for sorting and aggregation of the `_id` indices if needed
- Adjust Elasticsearch XPack SSL security settings if required

Most issues come from Elasticsearch 8 defaults being stricter than earlier versions

## Our Experience Upgrading Magento 2 to Elasticsearch 8

We have spotted a major issue post update, where your catalog and search pages might be looking a little sorry for themselves... with ZERO products! Not ideal.

There are a few configuration changes that are required to get Elasticsearch 8 to play nicely with Magento, that are easily overlooked in the upgrade notes (or absent entirely!). Don't forget to reindex and cache clean after each step!

Below are the most common causes we’ve seen for missing products and broken search after an Elasticsearch 8 upgrade, along with how to fix each one.

## Common Errors & What they Mean

### Index / Cache
Lets start at the very basics, the data on the catalog search pages are powered by the index and cache. Make sure these are populated and are up to date, as if they are missing, your products wont display.
```sh
php bin/magento index:reindex
php bin/magento cache:clean
```

### Correct Search Engine
Make sure your search engine is configured correctly in Magento. Elasticsearch8 uses different keys to Elasticsearch7 so if you have altered these, now is your chance.

These are just standard System Configuration options, so you can change these in a few ways. Within the Admin, or in your `app/etc/config.php` and `app/etc/env.php` files, or via CLI (included below).
```sh
php bin/magento config:set catalog/search/engine elasticsearch8
php bin/magento config:set catalog/search/elasticsearch8_server_hostname localhost
php bin/magento config:set catalog/search/elasticsearch8_server_port 9200
php bin/magento config:set catalog/search/elasticsearch8_server_timeout 15
```

### Missing Elasticsearch8 Package
Magento 2.4.6, 2.4.7 does not ship with the Elasticsearch8 package for some reason, despite being the only supported version!

If you don't have the package installed already (usually `./vendor/magento/module-elasticsearch-8/`). Then include it within your composer file
```sh
composer require magento/module-elasticsearch-8
```

### Elasticsearch _id indices
Elasticsearch8 disabled sorting and aggregation in the `_id` field by default for performance reasons, this functionality was deprecated in `ES 7.6`.

We can re-enable this functionality by adding the following files to your elasticsearch configuration file `/etc/elasticsearch/elasticsearch.yml` or via appropriate environment variables:
```
indices:
  id_field_data:
    enabled: true
```

This can be tested for by looking for a error message in your Elasticsearch logs similar to `Fielddata access on the _id field is disallowed, you can re-enable it by updating the dynamic cluster setting: indices.id_field_data.enabled"`

### Elasticsearch XPack SSL Security
Elasticsearch 8 ships with stronger security defaults, you can disable this temporarily to get your store back up and running while you investigate implementing it properly.

Todo this either edit your elasticsearch config file `/etc/elasticsearch/elasticsearch.yml` or provide the keys in environment variables to Elasticsearch, with the following config
```
xpack.security.enabled: false
xpack.security.enrollment.enabled: false
xpack.security.http.ssl.enabled: false
xpack.security.transport.ssl.enabled: false
```

### Index not supported
If you are switching between versions of Elasticsearch, you may encounter an error where your current version of Elasticsearch might not be able to read the indexes of an older version. We find this most prevalent within local development environments. All you need todo is drop your old index data and trigger a reindex. An example for this, if your using [Warden](https://warden.dev) is:
```
warden env elasticsearch down -v
warden env up
warden shell -c "php bin/magento index:reindex; php bin/magento c:f"
```
