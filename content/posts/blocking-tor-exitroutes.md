---
title: "Blocking TOR exit routes"
description: "How do we go about blocking TOR / Onion traffic to our site?"
date: 2024-07-22T06:00:00+00:00
tags: ["security", "sysops", "sre"]
author: "Me"
draft: false
---
One of my clients have recently seen a surge in TOR traffic with zero conversion from them. And has requested for them to be blocked, since its no point in autoscaling the infrastructure, leading to increased cost, for non converting anonymous traffic.

We have a few different ways to block TOR/Onion traffic, firstly we can just [click some buttons in cloudflare](https://community.cloudflare.com/t/tor-traffic-blocking/396979/3) and problem solved. But thats boring, and does not protect us if we move away from Cloudflare in the future (maybe they'll deem we are a 'enterprise' at some point 🙃). We have two other simple options, at the firewall (iptables in this case) or at the web server level. I am a fan of dropping traffic closest to the edge, so lets go over the firewall approach.


## IPTables / Firewall
First things first, lets install `ipset` if its missing. This simplies our setup and improves performance. Pick your poision.
```bash
apt-get install ipset
dnf install ipset
```

Next lets create a cronjob that will ensure we always have an upto date copy of the exit nodes (they can change overtime)
```bash
install -m 744 /dev/null /opt/update-ipset-tor-exitnodes

cat > /opt/update-ipset-tor-exitnodes<< EOF
#!/usr/bin/env sh
echo "create tor hash:ip family inet hashsize 1024 maxelem 65536" > /tmp/tor-exitnodes.txt
curl 'https://check.torproject.org/torbulkexitlist?ip=' | sed 's/^/add tor /' >> /tmp/tor-exitnodes.txt
ipset restore -! < /tmp/tor-exitnodes.txt
EOF

echo "0 0 * * * root /opt/update-ipset-tor-exitnodes" > /etc/cron.d/update-ipset-tor-exitnodes
```

Finally lets populate our ipset, before we can add our iptables rule to block the set.
```bash
/opt/update-ipset-tor-exitnodes
iptables -A INPUT -m set --match-set tor src -j DROP
```

Worth noting this approach can be used for any revolving public IP lists. Maybe you have a strange requirement to block cloudflare traffic, or to block certain web crawlers. Tweak this setup a bit, and you use it whitelist trusted crawlers with Nginx.
