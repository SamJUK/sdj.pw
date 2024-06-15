---
title: "Flushing Magento 2 Varnish Like a Pro"
description: ""
date: 2024-06-04T19:00:00+00:00
tags: ["magento2", "devops"]
author: "Me"
draft: false
---

Flushing Magento 2 cache is simple right? Just click the Orange "Cache Clear" button in the Admin, or run `php bin/magento cache:clean` from the command line. 
Speaking to other developers and merchants, this seems to be the way everyone deals with refreshing cached content. Even if its just affecting a single page or product.

It does not take a genius to realise flushing the entire Magento cache, means a significantly lower cache hit rate for the short term. They key impacts of this will be:
- Slower Page Loads
- Worse Core Web Vitals
- High Server Utilisation
- Potentially higher costs if autoscaling, as the service accommodates demand

On larger stores, this can amount to large costs & significant periods of slower response times (Especially on less frequently access pages).

So if flushing the entire catalog is not ideal, it should not take a genius to realise. We should only flush the content we need. Below we will list some of the most common scenarios.

---

## Flushing specific content from Varnish

We are going to be using primarily the `ban`command within the `varnishadm` tool. You want to run this command, while connecting to the server running Varnish.



### Flushing A Single Varnish Page
If we want to flush a single page from varnish, we can filter on `req.url` which will be the URI of the page. For example if we want to purge the contact page, we could run the following
```
varnishadm "ban req.url == /contact"
```

Now if we want to purge all pages starting with the word `test-` we could run
```
varnishadm "ban req.url ~ /test-"
```

If we want to target a single store / storefront, we can also include a filter on `req.http.host`
```
varnishadm "ban req.url == /contact && req.http.host == www.example.com"
```

### Flushing an entire Storefront / Site
If we want to flush an entire storefront / site, we can run the ban command, specifying just the `req.http.host`
```
varnishadm "ban req.http.host == www.example.com"
```

### Flushing Singular Products
Getting a bit more complex / Magento specific, we can flush singular products and all the category / CMS pages that product is referenced in. Todo this we can use the `X-Magento-Tags-Pattern` tag and the product ID.
For example if we want to flush product ID 512, we would use the following CURL Command
```
curl -XPURGE -H 'X-Magento-Tags-Pattern: (^|,)cat_p_512(,|$)' localhost:6081
```
