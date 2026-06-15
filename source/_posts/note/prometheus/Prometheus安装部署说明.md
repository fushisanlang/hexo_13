---
title: Prometheus安装部署说明
date: 2026-06-15
tags:
  - prometheus
  - grafana
  - 监控
  - node-exporter
categories:
  - note
---

Prometheus 二进制部署 + Node Exporter 采集 + Grafana 可视化的完整流程。

<!--more-->

## 1. 安装 Prometheus Server

### 下载并解压

```bash
cd /export/
wget https://github.com/prometheus/prometheus/releases/download/v2.13.1/prometheus-2.13.1.linux-amd64.tar.gz
tar -zxvf prometheus-2.13.1.linux-amd64.tar.gz
mv prometheus-2.13.1.linux-amd64 prometheus
```

### 配置文件 prometheus.yml

```yaml
# 全局配置
global:
  scrape_interval: 15s      # 抓取间隔
  evaluation_interval: 15s   # 规则评估周期

# Alertmanager 配置
alerting:
  alertmanagers:
    - static_configs:
        - targets:

# 规则文件
rule_files:

# 抓取配置
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

### 创建用户和数据目录

```bash
useradd -s /sbin/nologin -M prometheus
mkdir /export/prometheus/data -p
chown -R prometheus:prometheus /export/prometheus/
```

### Systemd 服务

```ini
# /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
ExecStart=/export/prometheus/prometheus \
  --config.file=/export/prometheus/prometheus.yml \
  --storage.tsdb.path=/export/prometheus/data
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

```bash
systemctl start prometheus
systemctl status prometheus
systemctl enable prometheus
```

访问 `http://IP:9090/graph`

## 2. Grafana 安装

### 下载并解压

```bash
cd /export
wget https://dl.grafana.com/oss/release/grafana-6.4.4.linux-amd64.tar.gz
tar -zxvf grafana-6.4.4.linux-amd64.tar.gz
mv grafana-6.4.4 grafana
```

### 创建用户

```bash
useradd -s /sbin/nologin -M grafana
mkdir /export/grafana/data
chown -R grafana:grafana /export/grafana/
```

### 修改配置

编辑 `conf/defaults.ini`：

```ini
data = /export/grafana/data
logs = /export/grafana/log
plugins = /export/grafana/plugins
provisioning = /export/grafana/conf/provisioning
```

### Systemd 服务

```ini
# /etc/systemd/system/grafana-server.service
[Unit]
Description=Grafana
After=network.target

[Service]
User=grafana
Group=grafana
Type=notify
ExecStart=/export/grafana/bin/grafana-server -homepath /export/grafana
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

```bash
systemctl start grafana-server
systemctl enable grafana-server
```

访问 `http://IP:3000/login`，默认账号 `admin/admin`

### 添加数据源

Grafana 页面 → Configuration → Data Sources → 添加 Prometheus，URL 填写 Prometheus 地址，Save & Test 即可。
