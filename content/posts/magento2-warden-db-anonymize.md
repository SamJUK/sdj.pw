---
title: "Anonymizing Magento 2 Databases with Warden"
description: "A simple guide for anonymizing Magento 2 databases in Warden to either pass off to other developers or move forward into staging/ephemeral environments"
date: 2024-05-21T19:00:00+00:00
tags: ["magento2", "warden", "devops"]
author: "Me"
draft: false
---
You might find yourself needing to anonymize a database in Warden to either pass off to another developer, or move it forward into ephemeral / staging environments. This is fairly easy to achieve with [Smile-SA GDPR Dump](https://github.com/Smile-SA/gdpr-dump).

First lets download the resources we need, we will store them in the dev folder as we can exclude this in our deployment pipelines.
```bash
wget https://github.com/Smile-SA/gdpr-dump/releases/latest/download/gdpr-dump.phar -o dev/gdpr-dump
wget https://raw.githubusercontent.com/Smile-SA/gdpr-dump/main/app/config/example.yaml -o dev/gdpr-dump.yaml
chmod +x dev/gdpr-dump
```

Next we can edit the yaml to set our correct Magento version and catch any non core tables we might have followed by running the anonymizer script.
```bash
DB_HOST=db DB_USER=magento DB_PASSWORD=magento DB_NAME=magento dev/gdpr-dump dev/gdpr-dump.yaml | gzip > dev/z_anonymized_db.$(date +%s).sql.gz
```

Now we should have a anonymized GZIP'd database we can share / move forward into environments.
