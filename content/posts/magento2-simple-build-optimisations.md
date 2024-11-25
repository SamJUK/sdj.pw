---
title: "Magento 2 Optimising Static Content Deploy"
description: ""
date: 2024-08-12T05:00:00+00:00
tags: ["magento2", "devops"]
author: "Me"
draft: false
documentation: https://docs.sdj.pw/magento/optimise-scd-build-process.html
---
Typically a lot of Magento 2 stores are slow to build, some taking up to and over an hour. This becomes a bigger pain point as stores grow and more themes & locales are added. Often optimising build time is often towards the bottom of the priority list. The [Magento Static Content Deploy Docs](https://experienceleague.adobe.com/en/docs/commerce-operations/configuration-guide/cli/static-view/static-view-file-deployment) provides a good amount of detail on this subject, and is a good read.

Just remember, typically, your pipeline execution time also affects your time to release fixes to critical production issues. As well as your CI spend.

Side Note: I think there is good scope to look at reimplementing the compilation commands in a faster language, maybe Go or Rust.

### Concurrency
We can enable concurrency which allows us to process multiple tasks at once in `static:content:deploy`. We can do this by setting the jobs flag `-j x` or `--jobs x`. But what should we set this value too? Simple answer is to use `nproc` to determine the value. nproc will give you the amount of free threads on the build machine.
```sh
php bin/magento static:content:deploy -j $(nproc) ...
```

### Areas
We can set the area of deployment with `--area` to either `adminhtml|frontend|all`. If you operate with a single locale, both frontend and admin, your best to leave this as all (or omit it). To avoid the bootstrap overhead on both commands.

But there are cases where its worth separating out our frontend and admin builds into separate commands. Maybe we provide multiple locales on the storefront (en_GB, fr_FR, de_DE). But only require en_GB on the backend. Or maybe we only provide a en_GB storefront. But our technical partners require their native locale in the admin.

### Themes
Next lets move onto themes. What do we need to deploy, or more accurately, what can we get away with skipping. It largely depends on your theme, I recommend a bit of trial and error here to figure out the minimum required. The important part here, is don't run this command with no flags. Or you will end up wasting a bunch of time/resources.

You can pass your themes via the `--theme samjuk/my-theme` flag. This will prevent Magento from deploying themes that are not in use.

The `--no-parent` flag will prevent Magento from deploying parent themes. It typically speeds up deployment a fair bit, and makes the process a bit more explicit. As it wont deploy inherited themes, unless specified.

### Locales / Languages
And the final part of the `static:content:deploy` command is locales. Again the goal here is to deploy the least amount locales. There is advice floating around the internet, that you have to always deploy the `en_US` locale. But in the current state of Magento this is false, and usually caused due to misconfigured administrator accounts.

We can run a simple SQL query against the database to determine what are the in-use locales.
```sql
--- List out all the locals we need to deploy
SELECT DISTINCT locale
FROM (
  SELECT value as locale FROM core_config_data WHERE path = 'general/locale/code'
  UNION SELECT interface_locale as locale FROM admin_user
) t;

--- Debug - List out which users are responsible for each locale being required
SELECT interface_locale as locale, GROUP_CONCAT(username) as Users FROM admin_user GROUP BY interface_locale;

--- Debug - List out which stores are using what locale
SELECT value as locale, GROUP_CONCAT(scope_id) as store_scopes FROM core_config_data WHERE path = 'general/locale/code' GROUP BY scope_id;
```

### Recap
In the end, you will want to play with different compositions of the command. Since deployment time can vary especially for deployments will a bunch of child theme / locales. And you goal should be to build the minimum amount of static content that we need for our deployment, whilst using multiple threads from the build host.
```sh
php bin/magento static:content:deploy --area frontend --no-parent --theme samjuk/base-theme --theme samjuk/french-theme en_GB fr_FR de_DE
php bin/magento static:content:deploy --area adminhtml --no-parent --theme Magento/backend en_GB
```
