---
title: "Magento 2 - Configuring Nginx Rate Limiting"
description: "A simple, no nonsense overview on how to configure rate limiting via Nginx for a Magento 2 website. Including IP and UserAgent whitelisting."
date: 2024-04-03T18:30:00+00:00
tags: ["magento2", "nginx", "devops"]
author: "Me"
draft: false
documentation: https://docs.sdj.pw/software/nginx/rate-limiting.html
---
Configuring Nginx rate limiting for Magento is both simple to get started, but complex to find the right balance. It is a great way to combat malicious traffic from web scrapers/crawlers, and less respectful 3rd party integrations. 

The default nginx status code for the limit is 503, it is important to change this to [HTTP 429 Too Many Requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/429). HTTP 429 is the standard rate limiting code, and should prevent any negative indexing results with search engines, and as a bonus any bots should slow their crawl rate (if they respect the response code).

Everysite is different, so its very important to operate in a dryrun / logging only mode initially when implementing new rules. When you supply the dryrun flag to nginx, it logs limits to the error log (see example below). Which allows you to review what traffic it would have blocked, and adjust your rules to be more or less restrictive. 
```
2024/04/03 17:35:17 [error] 3135#3135: *110166855 limiting requests, dry run, excess: 10.380 by zone "ip", client: xxx.xxx.xxx.xxx, server: site.example.com, request: "GET /some/path HTTP/1.0", host: "example.com"
```

## HTTP Block Config
We start with declaring the base rules alongside IP & User Agent whitelists in the http block within `nginx.conf`. With this configuration, with this configuration setting a IP or Useragent within the maps to `0` will cause them to bypass the limiting.

Note: You may want to tweak / remove the User Agent whitelist if its being abused on your site.

```bash
http {
  ...

  ## Rate Limits
  geo $limit_ip {
      default 1;
      # xxx.xxx.xxx.xxx 0; # Internal VPN
      # xxx.xxx.xxx.xxx 0; # Office IP
      # xxx.xxx.xxx.xxx 0; # Integration X
  }

  map $http_user_agent $limit_bots {
      default $limit_ip;
      ~*(google|bing|heartbeat|uptimerobot|shoppimon|facebookexternal|monitis.com|Zend_Http_Client|magereport.com|SendCloud/|Adyen|ForusP|contentkingapp|node-fetch|Hipex) 0;
      ~*(http|crawler|spider|bot|search|Wget|Python-urllib|PHPCrawl|bGenius|MauiBot|aspiegel) 1;
  }

  map $limit_bots $limit {
    0 '';
    1 $binary_remote_addr;
  }

  limit_req_dry_run on; # Enable this after you confirmed we are not restricting genuine traffic
  limit_req_status 429; 
  limit_req_zone $limit zone=ip:10m rate=10r/s; # Tweak this to adjust the amount of requests before we start rate limiting
  
  ...
}
```

## Server Primary Location Config

Next you want to configure the site to use the rate limit group. Update the primary location block in your Magento nginx config to something like below.

Magento is quite a burstiness application, alongside a document load, we might make a small handful of AJAX requests to the PHP-FPM process to grab data for the sidebar/checkout data, tracking etc. 
```bash
location ~ (index|get|static|report|404|503|health_check)\.php$ {
    limit_req zone=ip burst=10 nodelay; # Adjust the burstiness of the rate limit
    ...
}
```

## Custom Error Page

Lastly we want to display a informative branded error page incase customers do end up triggering the rate limit. We can configure this within our server blocks by declaring a custom error page. Then by placing a custom HTML page under `/var/www/public/ratelimited.html`
```bash
server {
  listen ...;
  server_name xxx.xxx;

  error_page 429 /ratelimited.html;
  location = /ratelimited.html {
    root /var/www/public;
    internal;
  }
  ...
```