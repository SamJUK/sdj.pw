---
title: "Debouncing Magento 2 FPC Purge Requests"
description: "Delaying Magento 2 full page cache purges to a set schedule, to improve frontend performance and reduce system load during busy periods such as sales events like black friday."
date: 2024-11-08T05:00:00+00:00
tags: ["magento2", "adobe-commerce", "devops", "performance", "site-reliability-engineering", "varnish"]
author: "Me"
draft: false
---

Heading into Black Friday, cache hit rates are a metric to monitor closely. Having poor cache performance, is likely to see dramatic increases in page load speed, higher autoscaling infrastructure costs, or even worse. 500 series errors. 

As part of our pre-emptive precautions, we have built an [experimental module](https://github.com/SamJUK/m2-module-cache-debounce) which intercepts and defers Varnish cache purges to a set schedule. 

We've rolled it out to some of the stores with problematic ERP systems and problematic store admins... Hopefully we can leave it disabled the entire time, but its a nice piece of mind.

From some biased lab testing, it appears to have a significant performance impact as expected. Visit the [Github Repository](https://github.com/SamJUK/m2-module-cache-debounce?tab=readme-ov-file#proof-of-concept) for more information on the testing.

![Magento 2 performance data comparison with FPC debounce module](https://github.com/SamJUK/m2-module-cache-debounce/raw/master/.github/poc.png)