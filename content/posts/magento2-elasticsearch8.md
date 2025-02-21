---
title: "Magento 2 - Fixing Missing Products with Elasticsearch 8"
description: "Have your upgrade to Elasticsearch8 gone pair shaped? This short post will get you back up and running with 5 minutes."
date: 2024-04-24T19:00:00+00:00
tags: ["magento2", "elasticsearch"]
author: "Me"
draft: false
---
Have you upgrade to Magento 2.4.6 recently for the improved performance / support lifetime? Or maybe you have upgraded to 2.4.7 where Elasticsearch 8 is the only supported Elasticsearch Version now.

We have spotted a major issue post update, where your catalog and search pages might be looking a little sorry for themselves... with ZERO products! Not ideal.

There are a few configuration changes that are required to get Elasticsearch 8 to play nicely with Magento, that are easily overlooked in the upgrade notes (or absent entirely!). Don't forget to reindex and cache clean after each step!


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
