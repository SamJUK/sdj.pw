---
title: "Check if your Magento site is safe from CosmicSting (CVE-2024-34102)"
description: "How to guide on checking if your Magento 2 store is safe from the CosmicSting (CVE-2024-34102) exploit. And guidance on how to patch and secure your site if it is not."
date: 2024-07-07T11:30:00+00:00
tags: ["magento2", "security", "devsecops", "magento-cloud", "adobe-commerce"]
author: "Me"
draft: false
---
I've been sat on this post and POC for CosmicSting (CVE-2024-34102) for a little while, giving time for stores to patch the vulnerability. Chances are, if you still have not applied the patch your store will have been probed and compromised by now since there are a handful of POCs out in the wild.

So I highly encourage you to make sure the patch is applied (its simple, a single file diff). And to download and run a malware scanner such as [Ecomscan by SanSec](https://sansec.io/#ecomscan) (its free, although wont tell you the location of the infections). Since this allowed attackers to exfil any files on the server that the user running PHP had permissions for. It is highly advised you rotate your application key in `app/etc/env.php` as this will allow attackers to create new API tokens even after the patch is applied.

Now, onto check if your store is vulnerable. Over on [Github at SamJUK/cosmicsting-validator](https://github.com/SamJUK/cosmicsting-validator) I've released the POC we've used alongside a bash script to easily check across all the domains you host. We caught a few instances that we missed (public available demo stores & development sites) after piping in our exported DNS records.

### How do I patch CosmicSting (CVE-2024-34102)
That is fairly simple, and can be accomplished by applying the following diff. You can even apply this patch directly on the server via the `patch` tool by running `patch -p1 < /the/path/to/the/patch.diff`. Although typically we would apply this with the `cweagans/composer-patches`.

```diff
diff --git a/vendor/magento/framework/Webapi/ServiceInputProcessor.php b/vendor/magento/framework/Webapi/ServiceInputProcessor.php
index cd7960409e1..df31058ff32 100644
--- a/vendor/magento/framework/Webapi/ServiceInputProcessor.php
+++ b/vendor/magento/framework/Webapi/ServiceInputProcessor.php
@@ -278,6 +278,12 @@ class ServiceInputProcessor implements ServicePayloadConverterInterface, ResetAf
         // convert to string directly to avoid situations when $className is object
         // which implements __toString method like \ReflectionObject
         $className = (string) $className;
+        if (is_subclass_of($className, \SimpleXMLElement::class)
+            || is_subclass_of($className, \DOMElement::class)) {
+            throw new SerializationException(
+                new Phrase('Invalid data type')
+            );
+        }
         $class = new ClassReflection($className);
         if (is_subclass_of($className, self::EXTENSION_ATTRIBUTES_TYPE)) {
             $className = substr($className, 0, -strlen('Interface'));

```

