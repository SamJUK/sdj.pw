---
title: "OpenVPN Split Routing"
description: "Increase throughput, security and speed by enabling split routing for OpenVPN. With only a few lines of server configuration."
date: 2020-11-16T11:30:00+00:00
tags: ["openvpn", "vpn", "devops"]
author: "Me"
draft: false
---
When setting up a VPN you have the option to either route all traffic through, or only route specific traffic through it. Some of the benefits with split routing within a development team context are:
- Increased privacy
- Reduced VPN load, allowing more connections / less allocated resources
- Access to both local & VPN network resources while connected

## Server Configuration
Within your main server configuration file `server.conf` remove the line that looks like the following if it exists
```
push "redirect-gateway ..."
```
This line configures clients to route their default network gateway through the VPN. Causing all traffic including web & DNS lookups to go through the VPN.

To configure a IP address to be split routed, for example `1.1.1.1` you would include the following line in the main server config file
```
push "route 1.1.1.1 255.255.255.255 vpn_gateway"
```
You can include multiple push records for all the resources you want to route through the VPN. As well as using CIDR blocks to target whole IP ranges. 

And finally restart the openvpn server for your changes to take effect.



