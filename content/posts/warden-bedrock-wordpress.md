---
title: "Local Wordpress Bedrock Development using Warden"
description: "The secret configuration file you need to implement to get Roots Bedrock working with the warden.dev local environment"
date: 2024-03-26T11:30:00+00:00
tags: ["warden", "wordpress", "devops", "docker"]
author: "Me"
draft: false
documentation: https://docs.sdj.pw/warden/wordpress-bedrock.html
---
The last few years i recently migrated to using [Roots Bedrock](https://roots.io/bedrock/) to bootstrap new wordpress developments. It provides a host of extra features that makes wordpress half decent to work with, such as Composer support, ENV variables, ENV specific config, better directory structure etc. I suggest checking it out if you haven't already.

Anyway, since I mostly focus on Magento development. My goto local dev environment is [Warden](https://warden.dev) which does support standard Wordpress out the box, along with a few other PHP frameworks. Although there is a tiny bit of undocumented configuration to get Bedrock working properly.

## Configuration

Since bedrock has changed up the directory structure, we now only expose the `web` subfolder to the web. So we need to update the nginx root parameter to reflect this. This can be done by creating a `.warden/warden-env.yml` in your project root (where your warden `.env` file is located). And adding the following content, followed by reloading the environment with `warden env up`
```yml
version: "3.5"
services:
  nginx:
    environment:
      - NGINX_ROOT=/var/www/html/web
```

Last you need to merge/update the warden `.env` file to contain the roots variables. Annoyingly, bedrock & warden use some ENV variables with the same name. Luckily its not a major issue since the DB configuration needs to be the same within bedrock & warden anyway. Although, bedrock uses slightly different names for the DB user and DB Schema names, so we have to redeclare those. The minimum I've found to get bedrock working is appending the following below.
```
# Bedrock
DB_NAME=wordpress
DB_USER=wordpress
WP_ENV=production
WP_HOME=https://app.wordpress.test
WP_SITEURL=https://app.wordpress.test/wp
```
