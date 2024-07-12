---
title: "Simple 2 line fix for Polyfill.io Malware in Magento 2"
description: "A quick and easy two line fix configuration fix for the Polyfill.io Magento 2 Malware"
date: 2024-07-12T18:30:00+00:00
tags: ["magento2", "nginx", "devops", "devsecops", "security"]
author: "Me"
draft: false
showToc: true
TocOpen: true
---
A simple two line Nginx config update can remove any reference of the polyfill Malware from coming out of your store.

## What is the Polyfill.io Malware?
As you likely have already heard, the polyfill.io domain has been serving malware. And there is still a concerning number of sites that still are including scripts from that domain.

Cloudflare and Fastly have both released alternative services that only require a change of domain. These are `https://cdnjs.cloudflare.com/polyfill/` and `https://polyfill-fastly.io/`

If you have any sites that still reference the original polyfill domain `polyfill.io` it is advised you remove this dependency urgently. The best course of action is to download and serve this content as a local asset rather than relying on a CDN. Or by atleast replacing the CDN in use to a safe alternative. 


## 2 Lines Fix via Nginx Config
```nginx
...
# PHP entry point for main application
location ~ ^/(index|get|static|errors/report|errors/404|errors/503|health_check)\.php$ {
    sub_filter 'cdn.polyfill.io' 'cdnjs.cloudflare.com/polyfill';
    sub_filter_once off;
    ...
}
...
```

You can check if your version of Nginx includes the sub module by running `nginx -V | grep http_sub_module`.

If the module is present, then we can add the following two lines into our main location block within the Nginx configuration. 

If we have Nginx sitting between our site and the client making the request, then we can make use of the Nginx Sub module `ngx_http_sub_module`. This will allow us replace any polyfill.io references on the fly.


## Magento (Application level) Fix
And the best way to resolve this issue is on the application level. 

You can either do this by updating any modules loading scripts from the polyfill.io domain. Or if there is no update, you can write a composer patch https://github.com/cweagans/composer-patches to replace the url. This will then persist across fresh composer installs / updates.