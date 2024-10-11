---
title: "Automating Magento 2 Updates"
description: ""
date: 2024-10-14T06:00:00+00:00
tags: ["magento2", "devops", "testing"]
author: "Me"
draft: false
---

> 🔥 Hot Take: Stop offloading poor engineering practises onto clients.

There is no wonder merchants are apprehensive about using Magento 2, when we are quoting them excessive amounts to even keep their store up to date and secure. In some recent research, I've seen estimates in excess of 100 hours for an update. That seems wild to me! 

I've found Magento releases have been getting a lot more stable & bug free in recent years, especially since Adobes acquisition. At least in comparison with the early Magento 2 / Magento 1 days. We used to have "SUPEE-xxx potential issues?" threads popping up on stack exchange before the updates even dropped.

Before we get started, this is not a walkthrough/tutorial, instead just some ideas for you to run with. Every Agency / Client is different, different tooling, different modules, different risk appetites, different budgets.


## Common Arguments

Just to touch base over a few common arguments against automated updates I hear. 

### Software Requirement Changes (PHP,Elasticsearch,MySQL versions)

Have a look into infrastructure as code (IaC) and containerised environments. When done right, it should be as simple as updating version numbers in a manifest file and letting your CI pipeline handle the rest.

### Updates keeps breaking our customisations

Sure, this one has a bit more merit. Although a lot changes I see break during updates have not been implemented correctly. Things such as using preferences, using plugins on API classes, deprecated methods etc. 

And when issues due occur, you should have Unit test coverage for any customisations done. If your running Unit tests on the automatically opened PR... Then you got a task list already curated for you!

### Third Party Module Lack Support for the Release

Most vendors get the updates the same time as us, so it can take a little while for modules to reach compatibility. Although your Unit / E2E tests should be failing, highlighting the faults in the update PR. And your PR should be updating each time a vendor releases an update, until eventually your tests pass and you can merge. Entirely hands free!

And if your modules take ages to each compatibility / never do... Then pick better vendors.

## Testing
If we look at the time associated with applying Magento updates, the vast majority is testing the stores to make sure it all works as intended.

So automate it. A well established test suite, will provide a wealth of confidence into your deployments / QA process. With enough time and attention, you can even omit most if not all manual testing.

- Implement End to End testing (E2E), ensure that key functionality works as intended. Login? Register? Add to Cart? Checkout?
- Implement Unit Tests.
- Performance testing, Blackfire.io can run in your CI pipeline and flag up any performance regressions.
- Core Web Vitals, running Lighthouse in your CI can highlight potential CWV regressions before deploying and waiting on RUM alarms.
- Visual Regression Testing, did your template change only affect the areas you expected?
- Code Static Tests. Security, Functional, Code Style etc


## Dependencies / Modules
Pick extension partners wisely, and stop installing any module you come across.

Ensure your dependency constraints are setup correctly, by decide your stability appetite. If you are risk adverse, only allow patch updates to modules. If you are not extending modules or doing so properly, maybe you can also allow minor version changes.

If a module keeps releasing breaking changes without increment the major version, Bin it.


## Dependency Management
There is plenty of CI tooling available that offer dependency management. Dependabot and Renovate and two popular examples. These will automatically generate new PRs to bump your package constraints to the newest version.


## Ephemeral Environments
Having automatic ephemeral environments (aka. feature environments) setup is really handy. Especially when using recent anonymised production data. Creating them on a PR to pre production, combined with something like Dependabot / Renovate. Removes the whole need for developers to be apart of updates (unless there is incompatibilities). Instead QA/PM can just pickup the Ephemeral hosts, test and promote through the environments to production.


## Infrastructure
How do you handle updates that require software version increases? Elasticsearch 7 -> 8? PHP 8.3 -> PHP 8.4? This I can't answer for you, maybe as a separate post. There is tons of ways to deploy Magento to production. Kubernetes, Docker, Bare Metal, Mutable, Immutable etc.

Recommend keeping your software up to date for security and performance benefits. Most Magento releases that contain a software version update do come with an overlap. So after updating the Magento version, you can then initiate the process of updating the supporting infrastructure to the latest version.


I might come back and dive a bit deeper in specifics / technical implementation details around some of the points above.
