---
title: "Cloudflare Outage November 2025 - Retrospective"
description: "Cloudflare accidentally took half the internet down for half a day, right before Black Friday. What can we learn from this, and how can we engineer more resilient infrastructure to survive similar outages in the future?"
summary: "Cloudflare accidentally took half the internet down for half a day, right before Black Friday. What can we learn from this, and how can we engineer more resilient infrastructure to survive similar outages in the future?"
date: 2025-11-19T21:00:00+00:00
tags: ["magento2", "devops", "site-reliability-engineering"]
author: "Me"
draft: false
---

I've seen multiple takes on this, from people writing it off as an acceptable loss, to others shouting about how the outage did not affect them due to using alternative providers. 

Both of these, are bad takes in my opinion, and we should always look internally for improvements that can be made.

1. Outages can and do happen to every provider. So winning the RNG lottery this time is not a long term solution.

2. Whilst the outage was recovered fairly quick this time. What if it was more severe? Multiple days? Data loss?


## TL;DR

The outage highlights the importance of implementing High Availability / Redundancy / Disaster Recovery strategies at all levels in your stack, including DNS.

1. Don't go all in with a single provider - Keep your domain registrar & DNS providers separate to improve your chances of surviving an outage and keep control.
2. Keep your DNS configuration as IaC - Allowing you to easily rebuild and switch your configuration with another provider quick and easily (most companies do not even have their own backup of zone files, do you? 👀)
3. Do not rely on Edge protection alone - Ensure you still maintain rate limiting / WAF / IP whitelists on the application layer as well (Nginx/HAProxy etc). Allowing you to disable the WAF / change provider if necessary
4. If you do not use any provider specific features if your primary name servers (WAF, Rate limiting etc) implement a secondary Zone with a different provider.


## What is my personal takeaways?

Personally, I got lucky that Terraform was still able to interact with the Cloudflare API. And that disabling the CF proxy, mitigated the outage. And that rotating the ingress IPs post resolution is a fairly simple task.

Although, this did highlight some other oversights, which could be improve for future resilience. 

Primarily, that my config was Cloudflare specific. Meaning to migrate to another DNS provider, I would need to rewrite the entire config for every DNS zone. - Which would be a lot of work

Instead I plan to migrate the terraform config into a separate module, with a common interface that can be shared across multiple DNS providers. As well as writing a few modules for alternative providers, improving the resolution time of switches in the future.

This will allow us to rebuild the DNS on another provider, and instrument NS record changes at the registrar in the case of an outage. Within the matter of minutes, not days.