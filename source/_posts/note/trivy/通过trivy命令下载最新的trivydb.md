---
title: 通过trivy命令下载最新的trivydb
tags:
  - trivy
categories:
  - note
abbrlink: 7bd9c6c5
date: 2025-01-14 00:00:00
---
## 前言
因为国内网络原因，自动更新db的trivy经常遇到更新db时候超时。   
经过研究发现trivy的时候可以跳过更新，但是会导致db老旧，有时候会无法扫描到最新的漏洞。   
所以找了一个折中的办法，在外网机器上通过定时任务定时下载最新的db，然后再传到trivy服务器上做扫描。

## install trivy command
```bash
# 这里也可以直接下载编译好的二进制命令文件，不过为了保证后续能更新trivy的新版本，我这里加了一个apt源
sudo apt-get install wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

## get trivy db
```bash
TRIVY_TEMP_DIR=$(mktemp -d)
trivy --cache-dir $TRIVY_TEMP_DIR image --download-db-only
```