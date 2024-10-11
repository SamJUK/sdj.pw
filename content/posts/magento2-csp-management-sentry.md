---
title: "Managing Magento 2 CSP_Whitelist.xml rules with Sentry"
description: ""
date: 2024-06-07T06:00:00+00:00
tags: ["devops", "sentry", "csp"]
draft: true
---
CSP Whitelists can be a bit of a pain to Manage, especially when you are responsible for a bunch of projects. This post is specially aimed at how we can ease Management when using Sentry.io as the CSP Report host.

To set expectations a little, it is unreasonable to expect to hit Zero CSP Violations. Visitors browsers for example, can attempt to load in whitelisted external resources trigger violation reports.

Instead we aim to filter out the noise the best we can. There are a bunch of posts about this if you search "CSP Filter Reports", and it will largely depend on what service you are using to ingest the reports. Sentry is just ok, nothing special in the area. We are actually considering alternatives due to this, but that's a post for a separate day.

### Configuring Magento to report to Sentry
First of all we need to grab the Sentry.io endpoint, this can be found in Sentry under Project Settings > Security Headers.

Next we want to configure the report URI in Magento, the following Magento doc explains it well https://developer.adobe.com/commerce/php/development/security/content-security-policies/#report-uri-configuration. The Storefront & Admin default are the important fields here.

Great, now we should start seeing CSP reports appearing into Sentry, and we can further configure alerting etc.

### Converting the reports to whitelist rules
Collecting the rules is great, but how do we convert these into a Magento format? Manually going through the reports and writing rules, seems like a really repetitive and boring task to me. Especially if you are just starting to implement CSP or if you have a lot of projects.

I don't belive in just delegating the boring / unwanted tasks to Juniors/Interns, but that's worth a separate post all together. So instead we started building some universal golang scripts. That can help use take these CSP reports and merge them into existing an existing `CSP_Whitelist.xml` files.

Subscribing to the idea of a script should do one thing, and do it well. We ended up with three separate scripts.

`export-sentry-csp-violations.go` - This script takes in a sentry project, and will export all the CSP violations to a CSV format for further use. It can be avoided by using the built in Sentry Discover export functionality which is usually quicker but required manual interaction.

`generate-csp-whitelist.go` - This is the bigger script of the set, it takes a few files are parameters (violations csv, existing csp_whitelist, violation ignore list). It will handle converting the violation CSV into a whitelist and merging the existing whitelist together.

`deduplicate-csp-whitelists.go` - This script takes in multiple csp_whitelist.xml files, and will handle extracting rules that appear in more than X files into a new global csp_whitelist.xml file

We use the deduplicate script to generate an isolated whitelist file which we distribute via a composer module across all projects. And it contains all the trusted generic dependencies we see. Such as Google domains, Trustpilot, 3DS Challenge Pages etc

We then run these scripts via a scheduled CI task, generating a new branch and pull request for the changes created. We can then manually review these changes, make any adjustments needed (Sentry filters, ignore file) and commit.

### What next?

Whilst these tasks have definitely made working with CSP violations in Sentry a lot easier, I am still not sold on Sentry as our Report provider. It's lacking the filtering & analytics capacity I would like. With the collection of scripts we build, changing report provider should be as simple as replacing the export-sentry script which an implementing for the provider dumping a simple CSV file.

Maybe writing an ingest application (if one does exist already), and having them in our centralized logging might be a good idea. Certainly would provide us with much more control over the filtering, Visualisation, Alerting aspects of it.

I wonder if there is much scope for public release of a global CSP Whitelist, as well as a blacklisted dataset, for use in other services filters.
