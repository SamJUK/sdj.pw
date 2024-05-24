---
title: "Magento 2 - Elasticsearch 8 Fixing _id disallowed indices in Warden"
description: "The single configuration option you need to set to solve the 'Fielddata access on the _id field is disallowed' error within Magento 2 with Warden"
date: 2024-04-24T19:30:00+00:00
tags: ["magento2", "elasticsearch", "elasticsearch8", "warden"]
author: "Me"
draft: false
---

This post explains how to set custom Elasticsearch configuration within [Warden](https://warden.dev) to fix the `Fielddata access on the _id field is disallowed` error with Elasticsearch 8.
This is a follow on from a [earlier post](/posts/magento2-elasticsearch8/) explaining common ES8 configuration issues with Magento.

The error was are going to fix related to ES8 changing the default values for `_id` fielddata
```
Fielddata access on the _id field is disallowed, you can re-enable it by updating the dynamic cluster setting: indices.id_field_data.enabled"
```

### The Solution
Within your project root create a file at `.warden/warden-env.yml` with the following content
```yml
version: "3.5"
services:
  elasticsearch:
    environment:
      - indices.id_field_data.enabled=true
```

Now restart your warden environment `warden env restart`, followed by a reindex `warden shell -c "php bin/magento index:reindex; php bin/magento c:f"` and voila, you should now have a catalog again! 