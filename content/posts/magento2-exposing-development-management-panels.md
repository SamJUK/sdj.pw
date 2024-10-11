---
title: "Do not expose unauthenticated Magento 2 management panels"
description: "Here is your regular reminder to audit what scripts are being exposed in your deployment and indexed by Google."
date: 2024-10-17T06:00:00+00:00
tags: ["security", "magento2"]
author: "Me"
draft: true
---
Here is your regular reminder to audit what scripts are being exposed in your deployment and indexed by Google.

During a recent security audit for Magento 2 store belonging to a large global brand. We uncovered a PHP management script being exposed to the internet and indexed under the filename of `redr.php`.

Was this intentional by the development team? Or maybe more likely a malicious actor? 

![Newrelic Usage Graph depicting a drop in tracing data](/images/redr.jpg)

Either way allowing creation & management of Admin users, orders and even a SQL console via an unauthenticated endpoint is a bad idea. Especially when its been indexed by google, like in this case!

What is the takeaway from this? Pay attention to what your site exposes, and consider auditing your current setup to make sure this does not happen to you.

1. The nginx sample config shipped with Magento prevents this type vulnerability, by only executing whitelisted scripts in the pub/root directories.
2. Scan your side with SanSec / monitor it for potential Malware Infestation
3. Use google dorks to check google for unexpected indexed files e.g `site:example.com filetype:pdf OR filetype:sql`
4. Implement a immutable deployment strategy, where unexpected/malicious files cannot end up in production.
