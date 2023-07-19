---
title: 通过prometheus监控mysql及pxc
date: 2016-8-25
updated: 2016-8-26
tags:
  - prometheus
  - mysql
categories:
  - note
abbrlink: 12df73bc
---

### 环境说明

pxc安装的mysql集群

服务器系统为centos 7.8

<!--more-->

### 监控mysql服务器

* mysql服务器

```shell
# 可以通过node_exporter对服务器进行监控
tar xf node_exporter-1.0.1.linux-amd64.tar.gz
mv node_exporter-1.0.1.linux-amd64 /usr/local/prometheus/node_exporter

cd /usr/lib/systemd/system
vim node_exporter.service #创建系统服务

[Unit]
Description=prometheus.io
[Service]
ExecStart=/usr/local/prometheus/node_exporter/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target

systemctl daemon-reload

systemctl start node_exporter #启动
systemctl stop node_exporter #停止
```

* prometheus添加监控

```shell
vim prometheus.yml #添加相应节点
rule_files:   #规则部分，添加对应的监控规则
  - "/usr/local/prometheus_all/prometheus/rules.yml"

scrape_configs: #配置部分，添加相应节点
- job_name: 'pxc_node'
    static_configs:
      - targets: ['192.168.92.131:9100','192.168.92.132:9100','192.168.92.133:9100']
      
vim /usr/local/prometheus_all/prometheus/rules.yml #只添加了主机node_exporter挂掉的报警，可以根据需要添加不同规则
groups:
- name: pxc_node
  rules:
  - alert: server_status
    expr: up{job="pxc_node"} == 0
    for: 1s
    annotations:
      summary: "机器{{ $labels.instance }} 挂了"
      description: "报告.请立即查看!"

systemctl restart prometheus #重启prometheus。配置方法见《prometheus配置成系统服务》
```

* 访问prometheus的页面，在alert菜单里，可能看见相应规则。在status/target里，也可以看见相应的监控项。

### 监控mysql服务

```shell
#使用mysql_exporter对mysql服务进行监控
mysql -p  #创建监控用户
mysql> CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'yierer333';
mysql> GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
mysql> flush privileges;


tar xf mysqld_exporter-0.12.1.linux-amd64.tar.gz
mv  mysqld_exporter-0.12.1.linux-amd64 /usr/local/prometheus/mysqld_exporter

cd /usr/lib/systemd/system
vim mysqld_exporter.service #创建系统服务

[Unit]
Description=mysqld_exporter
After=network.target
[Service]
Type=simple
User=mysql
Environment=DATA_SOURCE_NAME=exporter:yierer333@(localhost:3306)/ #用户密码
ExecStart=/usr/local/prometheus/mysqld_exporter/mysqld_exporter --web.listen-address=0.0.0.0:9104
  --config.my-cnf /etc/my.cnf \
  --collect.slave_status \
  --collect.slave_hosts \
  --log.level=error \
  --collect.info_schema.processlist \
  --collect.info_schema.innodb_metrics \
  --collect.info_schema.innodb_tablespaces \
  --collect.info_schema.innodb_cmp \
  --collect.info_schema.innodb_cmpmem
Restart=on-failure
[Install]
WantedBy=multi-user.targe

systemctl daemon-reload

systemctl start mysqld_exporter #启动
systemctl stop mysqld_exporter #停止
```

* prometheus添加监控

```shell
vim prometheus.yml #添加相应节点
rule_files:   #规则部分，添加对应的监控规则
  - "/usr/local/prometheus_all/prometheus/mysql_rule.yml"


scrape_configs: #配置部分，添加相应节点
  - job_name: "mysql"
    static_configs:
      - targets: ['192.168.92.131:9104','192.168.92.132:9104','192.168.92.133:9104']
      
vim /usr/local/prometheus_all/prometheus/rules.yml #这里使用了mysqld_exporter github上的示例规则。未添加pxc相应监控。


groups:
- name: example.rules
  rules:
  - record: mysql_slave_lag_seconds
    expr: mysql_slave_status_seconds_behind_master - mysql_slave_status_sql_delay
  - record: mysql_heartbeat_lag_seconds
    expr: mysql_heartbeat_now_timestamp_seconds - mysql_heartbeat_stored_timestamp_seconds
  - record: job:mysql_transactions:rate5m
    expr: sum(rate(mysql_global_status_commands_total{command=~"(commit|rollback)"}[5m]))
      WITHOUT (command)
  - alert: MySQLGaleraNotReady
    expr: mysql_global_status_wsrep_ready != 1
    for: 5m
    labels:
      severity: warning
    annotations:
      description: '{{$labels.job}} on {{$labels.instance}} is not ready.'
      summary: Galera cluster node not ready
  - alert: MySQLGaleraOutOfSync
    expr: (mysql_global_status_wsrep_local_state != 4 and mysql_global_variables_wsrep_desync
      == 0)
    for: 5m
    labels:
      severity: warning
    annotations:
      description: '{{$labels.job}} on {{$labels.instance}} is not in sync ({{$value}}
        != 4).'
      summary: Galera cluster node out of sync
  - alert: MySQLGaleraDonorFallingBehind
    expr: (mysql_global_status_wsrep_local_state == 2 and mysql_global_status_wsrep_local_recv_queue
      > 100)
    for: 5m
    labels:
      severity: warning
    annotations:
      description: '{{$labels.job}} on {{$labels.instance}} is a donor (hotbackup)
        and is falling behind (queue size {{$value}}).'
      summary: xtradb cluster donor node falling behind
  - alert: MySQLReplicationNotRunning
    expr: mysql_slave_status_slave_io_running == 0 or mysql_slave_status_slave_sql_running
      == 0
    for: 2m
    labels:
      severity: critical
    annotations:
      description: Slave replication (IO or SQL) has been down for more than 2 minutes.
      summary: Slave replication is not running
  - alert: MySQLReplicationLag
    expr: (mysql_slave_lag_seconds > 30) and ON(instance) (predict_linear(mysql_slave_lag_seconds[5m],
      60 * 2) > 0)
    for: 1m
    labels:
      severity: critical
    annotations:
      description: The mysql slave replication has fallen behind and is not recovering
      summary: MySQL slave replication is lagging
  - alert: MySQLReplicationLag
    expr: (mysql_heartbeat_lag_seconds > 30) and ON(instance) (predict_linear(mysql_heartbeat_lag_seconds[5m],
      60 * 2) > 0)
    for: 1m
    labels:
      severity: critical
    annotations:
      description: The mysql slave replication has fallen behind and is not recovering
      summary: MySQL slave replication is lagging
  - alert: MySQLInnoDBLogWaits
    expr: rate(mysql_global_status_innodb_log_waits[15m]) > 10
    labels:
      severity: warning
    annotations:
      description: The innodb logs are waiting for disk at a rate of {{$value}} /
        second
      summary: MySQL innodb log writes stalling


systemctl restart prometheus #重启prometheus。配置方法见《prometheus配置成系统服务》
```

* 访问prometheus的页面，在alert菜单里，可能看见相应规则。在status/target里，也可以看见相应的监控项。

### 监控pxc集群

**研究中**
