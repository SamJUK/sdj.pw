---
title: "Chaos Engineering in Magento 2"
description: "Do you employ Chaos Engineering with your Enterprise scale stores? Where is why you should start restarting services and infrastructure at random."
date: 2024-10-07T06:00:00+00:00
tags: ["ramblings", "magento2", "devops", "site-reliability-engineering"]
author: "Me"
draft: false
---
Chaos. Those who know me, knows that I love a bit of chaos in my work. Data center caught fire? Server fell out the rack? Its like a free roller coaster. For someone who’s role is to reduce the chaos, I enjoy and thrive on it a little bit too much.

## Why implement Chaos Engineering practises?

This is where Chaos Engineering comes into play, nobody wants to be woken up at 3am because OOMKiller has decided your database is not important any more. Although scrambling over that notification at 9:32am on a Thursday morning is a lot more fun. (Especially when you are expecting potential issues during that time).

It is a great way to ensure your systems/infrastructure is resilient to failures, and that your monitoring/alerting solutions are setup correctly and effectively.

The amount of times I have inherited infrastructure to find a service has not been enabled, so does not restart on system reboot. Or that failover system we are paying thousands for, does not work since someone forgot to reload the config changes on the hot spare.

## How to implement Chaos Engineering?

This is where [Chaos Money by Netflix](https://netflix.github.io/chaosmonkey/) and similar tools come into play. Essentially what these tools do, is cause simulated problems in your infrastructure. Maybe kill a process, cause high CPU/Memory load, drop network traffic, restart the whole server.

The best part of this, is we can set a schedule. So curious little George, only decides to kill the database during set times and days. Treating these like potential Maintenance windows, blocking out releases and having Engineers on standby in case anything goes wrong. You can even enable chat notifications to Slack and other messaging tools, so you are aware of an issue even if your monitoring fails.

## What if I do not have fault tolerant infrastructure?

A lot of people thing chaos engineering is only for big enterprise scale infrastructure, where everything is clustered with multiple failover zones all running on Kubernetes.

Whilst that is a very good use case for it (personally, I consider it essential at that scale). You can also apply it on a much smaller scale with a few caveats. Applying Chaos engineering on non fault tolerant infrastructure, **IS** going to cause issues. Your site will go down, it will be inaccessible at times. Although is that really a bad thing?

We can configure the tools so they have the least customer impact, choosing quite hours. Only performing more ‘risky’ actions (e.g system restarts) less frequently etc. The tool does not need to be run every day, or even week. We can run the chaos schedule once a month, once a quarter to reduce the customer impact.

Personally for me, knowing that the server is going to gracefully handle OOMKiller events, system reboots, resource starvation at 3am is worth its weight in gold (even if that means 5 minutes planned downtime, once a month). And it certainly beats the website being down for hours because a service crashed and did not restart without nobody around to restart it.

## Summary

- I like Chaos, but planned Chaos is better than 3am Chaos
- Expected downtime once a month/quarter, is better than unexpected downtime once a year
- Invite Curious George to come play within your infrastructure, and sleep better
