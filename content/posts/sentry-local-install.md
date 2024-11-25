---
title: "Quick Start Guide To Self Hosting Sentry.io"
description: "A simple guide on how to get started installing & configuring self hosted Sentry with docker compose."
date: 2024-01-06T11:30:00+00:00
tags: ["monitoring", "devops"]
author: "Me"
draft: false
documentation: https://docs.sdj.pw/general/sentry/self-hosting.html
---
Frontend monitoring is a crucial part of running online ecommerce stores. Although in a Agency context, a lot of the SaaS options can get expensive quickly especially for smaller merchants. By self hosting Sentry, we can elevate a lot of this cost.

We are using [Hetzner](https://hetzner.cloud/?ref=qW0Iw3EN8gxX) as our host, due to the low cost and high specs of some machines in their server Auction. The machine specs in particular are: 14C/20T 2.5GHz i5-13500, 64GB Ram, 2TB Raid, Ubuntu 22

[The official Sentry Self Hosted Docs](https://develop.sentry.dev/self-hosted/) cover setup, recommended specs, and configure fairly well even if the docs are a little bit jumbled at times.

## Server Configuration
Installation is pretty simple, first install docker & docker compose on the machine.
```sh
sudo apt update -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install docker-ce docker-compose-plugin
sudo systemctl enable --now docker
```

Next clone the sentry self hosted repository into the installation path on the machine (we are going to use `/opt/sentry`)
```sh
mkdir -p /opt/sentry
git clone https://github.com/getsentry/self-hosted.git /opt/sentry
cd /opt/sentry
git checkout 24.1.0
# Make any changes to the configuration files under
# /opt/sentry/sentry/config.yml - e.g Google SSO, Slack/Discord Tokens,
# /opt/sentry/sentry/sentry.conf.py - e.g Single Org Mode, Sentry Features, Bitbucket Tokens,
sudo ./install.sh --report-self-hosted-issues
docker compose restart
```

Next you can look into configuring a cron to backup the sentry server regularly
