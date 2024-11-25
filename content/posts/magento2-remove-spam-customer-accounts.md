---
title: "How to delete spam customer accounts in Magento2"
description: "A collection of SQL queries to help identify and delete Magento 2 spam customer accounts in 2024"
date: 2024-05-24T16:00:00+00:00
tags: ["magento2", "devops"]
author: "Me"
draft: false
showToc: true
TocOpen: true
documentation: https://docs.sdj.pw/magento/spam-account-cleanup.html
---

## Summary
Over the last few years, we've noticed an increase in the complexity of spam bots signing up to Magento 2 stores. They used to just spam customer accounts using the same email/email domain likely on ending in `.qq.com` `.ru` etc. 
So it used to be easy to just bulk delete based on the TLD especially for sites that do no ship to China / Russia etc. 

Whereas the last few years I'm observing them using standard mail providers such as `gmail.com` or `outlook.com` along with name fakers for the account names. This coupled with slower registration rate, and realistic fake data in the other fields make it much hard to batch delete customers. 

There is a few ways we can still try to identify bot registrations though. They will require some human review to make sure we are not deleting genuine customers, and still might miss some accounts. But it should sort the vast majority of the accounts. 

The SQL queries include joins against the `customer_log` and `sales_order` tables to help identify genuine accounts from spam ones. We use these tables to gather if the customer has placed any orders, and when their last login was.


## Advertising
One reason for spam accounts being registered is them attempting to use your domain to advertise to email addresses to avoid spam blacklists. A good monitoring solution is likely to highlight this within your alerting/dashboards.

One way to try and identify these accounts in the database is searching the `firstname` and `lastname` columns for potential domains. As these fields usually will appear in the customer registration email, they are often targeted.
```sql
SELECT
  e.entity_id, email, firstname, lastname, e.created_at, e.updated_at, l.last_login_at, o.cnt
FROM
  customer_entity as e
LEFT JOIN
  customer_log as l ON l.customer_id = e.entity_id
LEFT JOIN 
    (SELECT count(*) as cnt, customer_id FROM sales_order GROUP BY customer_id) as o on o.customer_id = e.entity_id
WHERE
  firstname RLIKE '.*www.*|\\\\.(net|com|ru|co|cn|cz|uk)'
  OR lastname RLIKE '.*www.*|\\\\.(net|com|ru|co|cn|cz|uk)'
GROUP BY e.entity_id
```

## Advanced Email Addresses
It is fairly uncommon for most customers to include a + sign within their email address. Most internet uses does not even know this is an option. You will need to manually review each line, since a handful of these could potentially be legitimate customers but most will be bots.

```sql
SELECT
  e.entity_id, email, firstname, lastname, e.created_at, e.updated_at, l.last_login_at, o.cnt
FROM
  customer_entity as e
LEFT JOIN
  customer_log as l
    ON l.customer_id = e.entity_id
LEFT JOIN 
  (SELECT count(*) as cnt, customer_id FROM sales_order GROUP BY customer_id) as o on o.customer_id = e.entity_id
WHERE
  email LIKE '%+%'
GROUP BY e.entity_id
```

## Random Name Fields
Another signature of bot accounts I've observed recently is randomly generated strings similar to `TGoHfngNexaUju` or `kaYgQKXpOlURPSnI` within the name fields. These prove to be much more of a challenge to identify and bulk remove. Currently the best query I have found these is by filtering the name fields on the following conditions:
- Does not contain a space
- Length is more than 5 characters
- Is not full capitals
- If capitals make up 40% of the string
```sql
SELECT
  e.entity_id, email, firstname, lastname, e.created_at, e.updated_at, l.last_login_at, o.cnt
FROM
  customer_entity as e
LEFT JOIN
  customer_log as l ON l.customer_id = e.entity_id
LEFT JOIN 
  (SELECT count(*) as cnt, customer_id FROM sales_order GROUP BY customer_id) as o on o.customer_id = e.entity_id
WHERE
  (
    firstname NOT LIKE '% %'
    AND LENGTH(firstname) > 5
    AND CAST(UPPER(firstname) as BINARY) != CAST(firstname as BINARY)
    AND (LENGTH(REGEXP_REPLACE(firstname, '(?-i)[A-Z]', '')) / LENGTH(firstname)) < 0.6
  ) OR (
    lastname NOT LIKE '% %'
    AND LENGTH(lastname) > 5
    AND CAST(UPPER(lastname) as BINARY) != CAST(lastname as BINARY)
    AND (LENGTH(REGEXP_REPLACE(lastname, '(?-i)[A-Z]', '')) / LENGTH(lastname)) < 0.6
  )
GROUP BY e.entity_id
```