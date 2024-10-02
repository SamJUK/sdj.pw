---
title: "The Magento 2 Setup Endpoint is leaking your Magento Version"
description: "Have you explicitly disable the Magento 2 setup route in your web server configuration? The vast majority of sites scanned are showing this route as leaking your full Magento Version."
date: 2024-10-02T06:00:00+00:00
tags: ["magento2", "security"]
author: "Me"
draft: false
---

The default Nginx sample configuration, and htaccess files shipped by Magento have the `/setup/` route publicly accessible.
And this route displays your current magento version, including patch level. For all prying eyes to see.

Currently this affects all Magento versions up to `2.4.7-p1` (the latest at time of writing), including `2.4-develop`.

It is worth noting, I believe the web installed was removed in `2.4`. Is there any need for this route to continue to exist, apart from leaking version data?

![Example exposure of Magento version via the /setup/ route](/images/setup-version-exposure.png)


## Solutions / Fixes
There is a few simple solutions to this problem, I strongly suggest just disabling access to the `/setup/` route via your server configuration files (nginx conf or htaccess).
Or if for some reason, you want to keep access to this route for certain users, at least implement an whitelist for controlling access.
Although if you do not have access to these files, you can also just remove the version line from the setup view template.

### Nginx
```diff
 location ~* ^/setup($|/) {
     root $MAGE_ROOT;
     location ~ ^/setup/index.php {
+        deny all;
         fastcgi_pass   fastcgi_backend;

         fastcgi_param  PHP_FLAG  "session.auto_start=off \n suhosin.session.cryptua=off";
```


### Apache
Credit to [Serfe](https://github.com/Serfe-com) - [Github Comment](https://github.com/magento/magento2/issues/39227#issuecomment-2386758235)
```diff
--- setup/.htaccess
+++ setup/.htaccess
@@ -1,3 +1,6 @@
+Order allow,deny
+Deny from all
+
 Options -Indexes

 <IfModule mod_rewrite.c>

```

### Application
```diff
--- setup/view/magento/setup/index.phtml
+++ setup/view/magento/setup/index.phtml
@@ -10,7 +10,6 @@
     <main class="page-content">
         <section data-section="landing" class="page-landing">
             <img class="logo" src="<?= $this->basePath() ?>/pub/images/magento-logo.svg" alt="Magento"/>
-            <p class="text-version">Version <?= htmlspecialchars($this->version, ENT_COMPAT) ?></p>
             <p class="text-welcome">
                 Welcome to Magento Admin, your online store headquarters.
                 <br>

```


