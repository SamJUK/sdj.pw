---
title: "How to efficiently patch Magento 2 deployments at scale"
description: "Approaches to simply deploying urgent patches across a large inventory of Magento 2 deployments"
date: 2025-05-18T19:00:00+00:00
tags: []
author: "Me"
draft: false
---

Deploying patches is simple for in-house development teams or smaller Agencies maintaining only a few stores. Manually applying patches per project is simple, but doesn't scale well. Both from time cost and security exposure perspectives. 

If your optimistic and confident in your monitoring setup, patching can be less than a few hours of engineering time.

## Live Patching

Live patching is reserved for high severity security related patches (think CosmicSting, SessionReaper), that need to be released to production ASAP. Where we will typically skip the usual deployment/testing process and patch the current deployments.

This is a process that can be done in as little as 5 minutes, if your brave enough. Or a few hours if you opt to perform a slower rolling release.

```sh
curl https://raw.githubusercontent.com/magento/magento-cloud-patches/xxxx.patch > patches/CVE-2025-54236.patch
ansible-playbook -i inventories/acme_agency.yaml playbooks/patch.yaml -e patch_file=patches/CVE-2025-54236.patch
```

> ℹ **Bonus Tip:** You can start with targeting a single/smaller selection of hosts with the `--limit` flag. Then once confident push across the whole inventory.

Example: https://www.github.com/SamJUK/magento2-patching-examples/live-patching/README.md

## Maintenance Patching

Maintenance patching is where we want to get the patch out, across all deployments, but it is not time critical and we can wait for our automated dependency checkers & testing suites to execute.

One way to handle this, is to create a centralized composer patching package. Where we can declare a selection of patches, we want applied to the entire infrastructure. And require this package within the rest of our projects. 

```json
{
    "name": "acme-agency/m2-module-patches",
    "description": "Magento 2 Module containing all required M2 Patches",
    "extra": {
        "patches": {
            "*": {
                "CVE-2025-54236 (Session Reaper)": {
                    "source": "patches/CVE-2025-54236.patch",
                    "depends": {
                        "magento/framework": "<=104.0.0"
                    }
                }
            }
        }
    }
}
```

The big benefit to this approach, is we can declare the new patch in a single place (the composer package) and tag a new release. And since its just a composer package, our Dependabot/Renovate configurations should pickup the module update and raise pull requests across all the projects for the version bump. 

Now we (should) have the patch ready to be merged, after a quick check of the changelog and test results.

Example: https://www.github.com/SamJUK/magento2-patching-examples/maintenance-patching/README.md