---
title: minio笔记3-使用prometheus监控minio
tags:
  - minio
  - 存储
categories:
  - note
abbrlink: e2542243
date: 2022-11-28 02:00:00
---

# minio笔记3-使用prometheus监控minio
0. 提前下载mc客户端
[文档地址](https://min.io/docs/minio/linux/reference/minio-mc.html)

1. 获取token
```shell
mc alias set logbak ${url} ${user} ${pass} #logbak是自定义的别名
mc admin prometheus generate logbak # 为logbak存储生成一个token

结果：
scrape_configs:
- job_name: minio-job
  bearer_token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjQ4MjMyMjcyMjYsImlzcyI6InByb21ldGhldXMiLCJzdWIiOiJsb2diYWsifQ.2ph5f8GenNRH8vV-5A337ySndFaoMWxHRwlUG7581Q0P9wVoUeKDb0Rp8LxUOOHHL6naqnB5KmP1TiR77saaSw
  metrics_path: /minio/v2/metrics/cluster
  scheme: http
  static_configs:
  - targets: ['10.13.13.120:9000']

```

2. 配置prometheus
```shell
# 将上一步中的返回做以下调整：
# 1. 确认是否使用了https，如果使用了，需要将scheme更改为https
# 2.targets中，将集群所有地址一次写入。
# 将修改过的结果写入prometheus配置文件中，并重启prometheus
#注意ymal文件缩进

```

3. 分析收集的指标

通过prometheus的查询界面，可以查看到以下几个指标：
`minio_cluster_disk_online_total{job="minio-job"}[5m]`
`minio_cluster_disk_offline_total{job="minio-job"}[5m]`
`minio_bucket_usage_object_total{job="minio-job"}[5m]`
`minio_cluster_capacity_usable_free_bytes{job="minio-job"}[5m]`

上述四个是值得关注的指标，所有指标详见[官方文档](https://min.io/docs/minio/linux/operations/monitoring/metrics-and-alerts.html#minio-metrics-and-alerts-available-metrics)。

4. grafana监控表盘
minio官方发布了一个grafana表盘，id为13502，可以直接使用。
[模版地址](https://grafana.com/grafana/dashboards/13502-minio-dashboard/)

5. 基础报警设置

```yaml
#以下是minio官方给出的报警项
groups:
- name: minio-alerts
  rules:
  - alert: NodesOffline
    expr: avg_over_time(minio_cluster_nodes_offline_total{job="minio-job"}[5m]) > 0
    for: 10m
    labels:
      severity: warn
    annotations:
      summary: "Node down in MinIO deployment"
      description: "Node(s) in cluster {{ $labels.instance }} offline for more than 5 minutes"

  - alert: DisksOffline
    expr: avg_over_time(minio_cluster_disk_offline_total{job="minio-job"}[5m]) > 0
    for: 10m
    labels:
      severity: warn
    annotations:
      summary: "Disks down in MinIO deployment"
      description: "Disks(s) in cluster {{ $labels.instance }} offline for more than 5 minutes"
```

6. 配置MinIO控制台查询Prometheus
控制台还可以通过查询prometheus展示服务监控数据，不使用grafana也可以图形化展示，配置方法如下：
```shell
# 在集群的每个实例上执行
echo MINIO_PROMETHEUS_URL="{url}" >> /etc/default/minio #注意替换成自己的url
echo MINIO_PROMETHEUS_JOB_ID="minio-job" >> /etc/default/minio #这里minio-job是prometheus中配置的job_name
systemctl restart minio
```
此时通过`http://url:9001/tools/metrics` 就能看到图形化数据。