---
title: "How to install & configure PHP SPX in Warden for Magento 2"
description: "A simple installer script to allow you to setup and configure PHP SPX in a Warden environment for Magento 2"
date: 2024-05-23T18:00:00+00:00
tags: ["magento2", "devops", "performance", "warden"]
author: "Me"
draft: false
---

PHP-SPX is an free and open source profiling alternative to Blackfire/Tideways etc. The main benefits imo are, its free to use and how simple it is to setup < 60s

There is an open discussion within Warden, to install the PHP-SPX profiler into warden core. https://github.com/orgs/wardenenv/discussions/719

In the meantime while we wait for the PR to merge, I've created the following shell script to bootstraps the PHP-SPX installation & configuration for the current warden project.

## Quick Start
### Option 1 - Single use script
Great option for testing and evaluating PHP-SPX, running this on the host from the warden project root
```sh
curl https://gist.githubusercontent.com/SamJUK/b3becaf6723acf4208eb5b8d92ef24f4/raw/f93afe910067417f55efb8d15bf5f73232fde1a9/warden_install_spx.sh | sh
```

&nbsp;

### Option 2 - Global Installation
Use this option if you plan to install SPX for multiple warden projects or use it for a longer period
```sh
# Install the SPX installer to a generic location
curl https://gist.githubusercontent.com/SamJUK/b3becaf6723acf4208eb5b8d92ef24f4/raw/f93afe910067417f55efb8d15bf5f73232fde1a9/warden_install_spx.sh > ~/warden-install-spx.sh
chmod +x ~/warden-install-spx.sh

# Invoke the Install script for each project you want to use it on
cd ~/Projects/warden-magento2-store;
sh ~/warden-install-spx.sh
```
- Navigate to the SPX control panel e.g `https://app.magento.test/?SPX_KEY=dev&SPX_UI_URI=/`
- Ensure the Enabled & Automatic start boxes are ticked
- Navigate the pages you want to profile
- Go back to the control panel, your requests should be in the table at the bottom of the page.
- Click the requests you want to view in more detail

## Usage
Full usage guide can be found on the PHP-SPX github: https://github.com/NoiseByNorthwest/php-spx 

## Script Source Code
Full source code from the gist, for simplicity of showing what it does
```sh
#!/usr/bin/env sh
#
# A fairly simple shell script to install and configure PHP-SPX within a Warden.dev Environment
# 
# Usage:
#  - Download the script: `curl https://... > ~/warden-install-spx.sh` 
#  - Set Permissions on the script `chmod +x ~/warden-install-spx.sh`
#  - cd to your warden project `cd ~/Projects/magento.test`
#  - Run the downloaded script `sh ~/warden-install-spx.sh`
#
#  - Navigate to the SPX control panel `https://app.mywebsite.test/?SPX_KEY=dev&SPX_UI_URI=/` and enable profiling
#  - Hit the pages you want to profile
#  - Navigate back to the SPX control panel to view the traces
#
set -e

echo "-------------------------"
echo " Warden SPX Installation "
echo "-------------------------"

echo "[i] Checking if this is a Warden Project"
warden env config >/dev/null

echo "[i] Installing Dependencies"
warden shell -c "sudo yum install -y php-devel"

echo "[i] Downloading SPX Source Code"
warden shell -c "rm -rf /tmp/spx; git clone https://github.com/NoiseByNorthwest/php-spx.git /tmp/spx"

echo "[i] Building SPX Extension"
warden shell -c "cd /tmp/spx && phpize && ./configure && make && sudo make install"

echo "[i] Writing SPX Configuration"
warden shell -c "
cat - <<EOF | sudo tee -a /etc/php.d/99-spx.ini
extension=spx.so
spx.debug=1
spx.http_enabled=1
spx.http_ip_whitelist=*
spx.http_key=dev
spx.http_trusted_proxies=REMOTE_ADDR
EOF
"

echo "[i] Add Varnish Cache Bypass"
warden env exec varnish sh -c "sed -i '#^.*SPX_ENABLED.*$#d' /etc/varnish/default.vcl"
warden env exec varnish sh -c "sed -i 's#sub vcl_recv {#sub vcl_recv {\nif (req.url ~ \"SPX_UI_URI|SPX_KEY\" || req.http.Cookie ~ \"SPX_ENABLED\") { return (pass); }#g' /etc/varnish/default.vcl"

echo "[i] Reloading Varnish Config"
T=$(date +%s)
warden env exec varnish sh -c "varnishadm vcl.load reload$T /etc/varnish/default.vcl; varnishadm vcl.use reload$T;"

echo "[i] Restarting PHP-FPM Container"
warden env restart php-fpm
```
