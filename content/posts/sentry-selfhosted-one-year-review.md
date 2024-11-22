---
title: "Self Hosting Sentry.io for one year, what have we learned?"
description: "We have been self hosting Sentry.io in a Magento Agency setting for around a year now. And in short its been uneventful... which is a good thing. But what have we learned?"
date: 2024-11-25T05:00:00+00:00
tags: ["monitoring", "devops", "observability"]
author: "Me"
draft: false
---

In Short:
- Its very cost effective, we are seeing savings between £2500 and £3500 per month, over hosted estimates.
- Its been very stable (a setup and forget type situation)
- Updates are released fairly frequently, and are simple to apply
- Be very mindful of free disk space, it runs postgres which can massive pain to clean up when close to limits.
- Sentry's disk clean up functionality seems to be flaky
- The CSP functionality gets the job done 


## Cost

Cost is the leading factor to self hosting sentry for us, and its a win win scenario. As it becomes much more affordable for clients to opt for, and we get observability into the frontend health & metrics of the stores.

On average, we are ingesting between 9 & 11 million events per month across our clients. And we are hosting Sentry on a Hetzner dedicated server at the cost of ~ £30 per month. With the following specs: 14 Core i5-13500 @ 2.5GHz, 64GB Ram (2x 32GB 3200 MT/s), 2x 500G NVMe SSDs in Raid 0

Running our usage through the the calculator on the Sentry.io homepage, and the cost comes out to ~$2700 per month. A massive difference!

&nbsp; | &nbsp; 
--- | ---
![Sentry Usage](/images/sentry-usage.png) | ![Sentry Estimate](/images/sentry-estimate.png)

## Management / Updates

The folks over at Sentry have done a good job with their self hosted offering, as its all based on docker compose. Any modern operator, who is familiar with docker, should be able to manage the stack on the surface. Things like installation, updates etc are very simple. 

The following doc is on how to bootstrap a new install in 5 minutes [https://docs.sdj.pw/general/sentry/self-hosting.html](https://docs.sdj.pw/general/sentry/self-hosting.html)

Although diving into the inner workings can get very complex quickly, there are over 50 containers! But its unlikely you will need to as the stack is very stable.

Always check the release notes prior to updating, hard stops & breaking changes do make an appearance, and you might need to alter your config prior to applying an update. 

We manage the stack via Ansible. To update the application, it is as simple as bumping the version in the playbook and commiting to GIT. Where the pipeline will invoke the playbook, which then will pull the latest release artifact onto the system and restart the compose application as needed.

## Disk Space

Be warned. Be very careful about how full your disk gets, as Sentry uses postgres as its database. And Postgres has a lovely quirk, where to free disk space back to the system, it recreates a new table with the deleted data missing BEFORE deleting the original table.

A google search for something along the lines of `postgres VACUUM table full disk` should reveal more. 

We have our disk space alert setup for 70% utilisation (~300G free) on the sentry server rather than the usual 85/90% on most other servers. 

## Sentry's Clean up (or lack of)

Sentry does have clean up functionality built in, where it will remove data past the configured retention date. Although our experience is... not great. It almost caught us out in the beginning hence why we've opted for the very lenient disk space alerting strategy. Although its only been triggered once or twice.

If you do find yourself in a corner with low disk space the following doc might help: 
[https://docs.sdj.pw/general/sentry/disk-space-cleanup.html](https://docs.sdj.pw/general/sentry/disk-space-cleanup.html)

You can find related topics when searching the Github issues for the phrases like "[cleanup](https://github.com/getsentry/self-hosted/issues?q=is%3Aissue%20cleanup)" or "[retention](https://github.com/getsentry/self-hosted/issues?q=is%3Aissue%20retention)"

## CSP Reporting

We have also been using the CSP reporting functionality the better part of the last year, and its functioned well. There are better solutions out there, but Sentry was already deployed across the clients and since we self host, it does not affect our quotas (just disk usage).

We have built some Golang tooling, that handles exporting recent CSP errors from the Sentry API or via manual CSV export ignoring predefined bad patterns (think `chrome-extension://` etc). The [csp-wtf github project](https://github.com/nico3333fr/CSP-useful/tree/master/csp-wtf) is a very good source for identifying the junk reports.

Then this is marshalled into the `csp_whitelist.xml` format and merged against the existing config for the relevant project. Where a PR is then opened for manual review.

## Summary

In short self hosting Sentry.io has been a mostly painless experience (minus the initial 95% disk usage debacle). The dev team are happy with error & CSP reporting, core web vitals, session replays across all the clients. The clients are happy with saving hundreds/thousands per month on monitoring. And I'm happy with the stability/ease of operation of the solution.