---
title: "Self-Hosted Sentry Setup with Docker - Quick Start Guide"
description: "A step-by-step guide to installing and configuring self-hosted Sentry with Docker and Docker Compose for monitoring ecommerce stores."
date: 2024-01-06T11:30:00+00:00
tags: ["monitoring", "devops"]
author: "Me"
draft: false
documentation: https://docs.sdj.pw/general/sentry/self-hosting.html
---
Frontend monitoring is essential for running online ecommerce stores. For agencies and smaller merchants, SaaS monitoring solutions can become expensive quickly. By performing a **self-hosted Sentry setup using Docker and Docker Compose**, you can maintain full monitoring capabilities at lower cost while keeping control over your infrastructure. This guide walks you through server setup, installation, configuration, and backup for a self-hosted Sentry instance.

## TL;DR
- Set up a server (Hetzner recommended) with Ubuntu 22.04  
- Install Docker & Docker Compose  
- Clone the Sentry self-hosted repo to `/opt/sentry` and checkout your desired version  
- Customize `/opt/sentry/sentry/config.yml` and `/opt/sentry/sentry/sentry.conf.py`  
- Run `./install.sh --report-self-hosted-issues`  
- Schedule regular backups with cron
- Automate monitoring with Docker and Docker Compose

This guide provides a complete, self-hosted Sentry setup using Docker and Docker Compose for ecommerce monitoring, including installation, configuration, and automated backups.

## Prerequisites
- A server with Ubuntu 22.04 (Hetzner recommended for low cost and high specs: 14C/20T 2.5GHz i5-13500, 64GB RAM, 2TB RAID)  
- Basic knowledge of CLI, Docker, and system administration  
- Access to GitHub to clone the Sentry repository

### Install Docker & Docker Compose
```bash
sudo apt update -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install docker-ce docker-compose-plugin -y
sudo systemctl enable --now docker
```

## Installing Sentry Self-Hosted
Now that our server is prepared with Docker and Docker Compose, we can proceed to install Sentry Self-Hosted.

### Clone and Configure Sentry Self-Hosted
```bash
mkdir -p /opt/sentry
git clone https://github.com/getsentry/self-hosted.git /opt/sentry
cd /opt/sentry
git checkout 24.1.0
```

> Note: Check the [official Sentry releases](https://github.com/getsentry/self-hosted/releases) to use the latest stable version.

### Configure Sentry

Customize the following files as needed:
- `/opt/sentry/sentry/config.yml` — e.g., Google SSO, Slack/Discord Tokens  
- `/opt/sentry/sentry/sentry.conf.py` — e.g., Single Org Mode, Sentry Features, Bitbucket Tokens

### Run Installation Script
```bash
sudo ./install.sh --report-self-hosted-issues
docker compose restart
```

## Backup & Maintenance

Regular backups are essential to protect your Sentry instance from data loss or system failure. For full instructions, refer to the [Sentry documentation on backups](https://develop.sentry.dev/self-hosted/backups/).


## References
- [Official Sentry Self-Hosted Documentation](https://develop.sentry.dev/self-hosted/) — full setup, configuration, and maintenance guides  
- [Hetzner Cloud](https://hetzner.cloud/?ref=qW0Iw3EN8gxX) — recommended hosting provider for self-hosted Sentry