---
title: "Debugging Varnish Cache Performance in Magento 2"
description: "Quick reference guide to debugging Varnish usage within Magento 2, covering cache utilisation, hit & miss rate logging, identifying the source of purge requests"
date: 2024-09-20T06:00:00+00:00
tags: ["magento2", "varnish", "debugging", "performance"]
author: "Me"
draft: false
documentation: https://docs.sdj.pw/software/varnish/debug-cache-performance.html
---
I do a fair bit of performance oriented consulting/contracting work with Magento Agencies / Developers. A common theme seems to be difficulty monitoring/debugging Varnish.

## The Varnish Service

### Watching a specific URLs Age
We can monitor how long a specific URL is staying in cache, by wrapping a curl command within a while loop. (Note: You may need to update your varnish config to stop removing the Age header)
```sh
while true; do curl -Iso /dev/null -w '[%header{Date}] %{http_code} %{url} %header{x-cache} %header{age}\n' https://example.com && sleep 1; done
```

### Checking if you have allocated enough memory to Varnish
We can use the `varnishstat` command, to see how many items have overflowed the varnish cache or if we have over provisioned our varnish cache. If `n_lru_nuked` is above zero or `g_space` is a low, you likely want to consider potentially increase your memory allocation for Varnish.
```sh
varnishstat -1 -f "SMA.s0.g_*" -f MAIN.n_lru_nuked -f MAIN.n_object
```
Field | Description
--- | ---
`n_lru_nuked` | This value is how many times an item has been discarded from the cache due to having no space for a new item. (This should be zero or fairly low)
`g_bytes` | This is how much of the varnish cache storage is currently being used
`g_space` | This is how much of the varnish cache storage is left over to be assigned to new content


Using the output of the above command, we can adjust the available cache storage for varnish by editing the system file and updating the malloc value.
```sh
systemctl edit --full varnish
# Update the ExecStart line, and update the malloc value appropriately
```


### Enable ongoing persistent logging
We can log varnish requests including hit/miss rates just like Nginx requests by using Varnishncsa. This is great for ingesting into your observability stack (NewRelic/Grafana/OpenTelemetry etc).
Great for creating pretty graphs and dashboards or trigger notifications when items are being evicted from cache or if hit rate drops below a preset value.
```sh
echo '%{X-Forwarded-For}i %{Varnish:hitmiss}x %l %u %t "%r" %s %b "%{Referer}i" "%{User-agent}i" %D' > /etc/varnish/varnishncsa.format
systemctl edit --full varnishncsa # Add -f /etc/varnish/varnishncsa.format to the end of ExecStart
systemctl enable --now varnishncsa
```

## Magento

### Enable Cache Invalidation Logging
If you have PURGE requests coming from Magento, but are unsure what is triggering it. You can enable debug logging by running the following commands, and this will start logging some `cache_invalidate` entries to the `system.log` file.
```sh
php bin/magento setup:config:set --enable-debug-logging=true && php bin/magento cache:flush
```

Alternatively if you do not want to change the config setting, you can edit the `execute` method within `vendor/magento/framework/Cache/InvalidateLogger.php` and change the log to info/warn level to enable logging in non debug mode.

### Cache Invalidation Stack Traces
Sometimes the you need a bit more information about whats triggered the cache invalidate than just the method & URL. 
We can add the backtrace for the cache invalidation logs by editing the `makeParams` method within `vendor/magento/framework/Cache/InvalidateLogger.php` 
```diff
 private function makeParams($invalidateInfo)
 {
     $method = $this->request->getMethod();
     $url = $this->request->getUriString();
+    $trace = (new \Exception)->getTraceAsString();
+    return compact('method', 'url', 'invalidateInfo', 'trace');
-    return compact('method', 'url', 'invalidateInfo');
 }
```