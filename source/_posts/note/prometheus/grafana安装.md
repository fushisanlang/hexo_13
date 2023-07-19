---
title: grafana 安装
date: 2020-6-12
updated: 2020-6-13
tags:
  - grafana
  - 监控
categories:
  - note
abbrlink: 362b0ed6
---


### grafana 安装



[ubuntu/debian](https://grafana.com/docs/grafana/latest/installation/debian/)

```shell
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/enterprise/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list 

echo "deb https://packages.grafana.com/enterprise/deb beta main" | sudo tee -a /etc/apt/sources.list.d/grafana.list 

sudo apt-get update
sudo apt-get install grafana-enterprise

sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
```

[redhat/centos](https://grafana.com/docs/grafana/latest/installation/rpm/)

```shell
vim /etc/yum.repos/grafana.repo

[grafana]
name=grafana
baseurl=https://packages.grafana.com/enterprise/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt

yum install grafana

sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
```

