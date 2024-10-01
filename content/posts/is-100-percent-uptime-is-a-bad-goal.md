---
title: "Is 100% uptime a bad goal?"
description: "Should you aim for 100% uptime across your servers? Or instead target fluid infrastructure where short lived nodes can spawn and die as required?"
date: 2024-10-14T06:00:00+00:00
tags: ["ramblings", "sysops", "security"]
author: "Me"
draft: false
---
I hear the claim of 100% uptime thrown around a lot. Although is 100% uptime really a good goal to have?

Like most things in tech, the answer is, it depends. If your running your Magento store within a fault tolerant cluster, sure 100% website uptime is a good goal. Whereas if your are running Magento on a single instance, or even multiple servers but not in a cluster. Then claiming to aim for 100% uptime is more of a red flag than something to be proud of. 

## Why do I think 100% uptime is bad?

How do we update system level applications such as PHP-FPM, Varnish, Nginx, MySQL? With a bit of system gymnastics, we can update some of the applications with minimal interference (although is it *true* 100% uptime?). Or the big question, what about kernel updates? 

The vast majority of the time when I look at a new server, uptime is in the hundreds of days with hundreds of packages are in need of being updated. Un-applied Kernel updates are lurking, and the system is crying for a restart to apply updates that have been downloaded.

The bottom line is you cannot have a long running server that is fully patched without performing system restarts. And restarting the server means service outage in single instance deployments.

Sadly Most people choose uptime over security.

## Achieving 100% service uptime

As we gather, I disagree with 100% system uptime. Servers need to be restarted to stay secure and functional. Although is there a case where we can have 100% service uptime, without having to have 100% system uptime? 

Of course, this is where having your applications deployed as clusters becomes very useful. 

As we can single out specific servers, drain their traffic, remove them from the cluster and perform the relevant maintenance. Before reintroducing them to the cluster and actioning the remaining nodes. 

## Merchant Sizes

Is the cost of running clustered infrastructure beneficial for SMBs? Typically not, although that's a business decision based on the extra cost compared to lost revenue during the relevant maintenance window.

Some teams even like to perform maintenance during the early hours. (Personally Im not a big fan, the health of my Engineers always triumphs a bit of lost revenue. But that is a topic for a different post)

When it comes to larger stores, where we measure orders per minute rather than per hour. 100% uptime becomes more a requirement than goal. Although at this scale, your infrastructure should be mature enough and more than capable of 100% service uptime. 

## Summary

- 100% system uptime = Always Bad
- 100% service uptime = Good (Although is it cost effective for the Merchant size?)
- I do not like out of hours maintenance periods, Engineers have families too.