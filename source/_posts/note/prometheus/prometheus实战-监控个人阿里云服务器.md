---
title: prometheus实战-监控个人阿里云服务器
tags:
  - prometheus
  - 监控
  - 部署实录
categories:
  - note
abbrlink: 5caf4d1f
date: 2022-03-25 00:00:00
---

## 项目背景
因为服务器部署的服务有点多，偶尔会有因为内存不足导致服务挂死的情况。
再者一直想做一个url的监控，来确认自己的服务运行正常。
之前本来想自己通过py写一个小的监控程序，后来考虑了一下之后觉得还是使用prometheus直接做监控。

## 前期问题
之所以最初想要自己写一个小程序是有以下两个原因：
1. 服务器性能一般，内存吃紧。
2. 外网带宽只有1m，在服务器上部署grafana，访问的时候加载速度很慢。
经过实际使用，发现整个prometheus组件对资源的使用程度很低。
至于数据展示，选择了在本地部署grafana的方式避免加载。目前来看整个系统运行正常。

## 整体架构
结合自己使用需求，总计在服务器上部署了prometheus的四个组件。
* prometheus
* node_exporter
* blackbox_exporter
* alertmanger

## 实际操作
*安装步骤略过，基本就是下载解压运行。为了方便管理服务，将所有服务都加到了系统服务中。具体可以参考[prometheus部署并配置成系统服务](https://www.fushisanlang.cn/article/4d24aa39.html)*

### node_exporter 和 blackbox_exporter
这两个本身未进行配置。node_exporter是因为没有配置余地。blackbox_exporter是因为我暂时只使用了http访问的功能来读取返回值，没做特别配置。

### alertmanger

#### 报警渠道
公司使用的是邮箱报警的方式，使用起来需要关注邮箱，个人觉得不太方便。
个人认为最理想的报警方式是微信，一个是日常使用，二是因为自己的服务少，即使出问题报警也不会很多，不会形成报警风暴。
但是因为现在微信自己的机器人不能用了，所以退而求其次使用企业微信。
企业微信可以通过微信接受消息，报警消息会推送到企业微信自建的应用中，通过微信提醒，这样算是可以变相实现微信报警。
alertmanger目前已经天然支持企业微信，直接配置即可。
至于邮件报警，可以参考[prometheus（普罗米修斯）入门使用](https://www.fushisanlang.cn/article/2cc11846.html)

#### 配置参考
```yml
global:
  resolve_timeout: 10m
  wechat_api_url: 'https://qyapi.weixin.qq.com/cgi-bin/'
  wechat_api_secret: '应用的secret，在应用的配置页面可以看到'
  wechat_api_corp_id: '企业id，在企业的配置页面可以看到'
templates:
- '/etc/alertmanager/config/*.tmpl'
route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  routes:
  - receiver: 'wechat'
    continue: true
inhibit_rules:
- source_match:
receivers:
- name: 'wechat'
  wechat_configs:
  - send_resolved: false  #这个参数定义了是否显示报警恢复消息
    corp_id: '企业id，在企业的配置页面可以看到'
    to_user: '@all'
    to_party: ' PartyID1 | PartyID2 '
    message: '{{ template "wechat.default.message" . }}'
    agent_id: '应用的AgentId，在应用的配置页面可以看到'
    api_secret: '应用的secret，在应用的配置页面可以看到'
```

#### 报警模版参考
```tmpl
{{ define "wechat.default.message" }}
{{- if gt (len .Alerts.Firing) 0 -}}
{{- range $index, $alert := .Alerts -}}
{{- if eq $index 0 -}}
告警类型: {{ $alert.Labels.alertname }}
告警级别: {{ $alert.Labels.severity }}

=====================
{{- end }}
===告警详情===
告警详情: {{ $alert.Annotations.message }}
故障时间: {{ $alert.StartsAt.Format "2006-01-02 15:04:05" }}
===参考信息===
{{ if gt (len $alert.Labels.instance) 0 -}}故障实例ip: {{ $alert.Labels.instance }};{{- end -}}
{{- if gt (len $alert.Labels.namespace) 0 -}}故障实例所在namespace: {{ $alert.Labels.namespace }};{{- end -}}
{{- if gt (len $alert.Labels.node) 0 -}}故障物理机ip: {{ $alert.Labels.node }};{{- end -}}
{{- if gt (len $alert.Labels.pod_name) 0 -}}故障pod名称: {{ $alert.Labels.pod_name }}{{- end }}
=====================
{{- end }}
{{- end }}

{{- if gt (len .Alerts.Resolved) 0 -}}
{{- range $index, $alert := .Alerts -}}
{{- if eq $index 0 -}}
告警类型: {{ $alert.Labels.alertname }}
告警级别: {{ $alert.Labels.severity }}

=====================
{{- end }}
===告警详情===
告警详情: {{ $alert.Annotations.message }}
故障时间: {{ $alert.StartsAt.Format "2006-01-02 15:04:05" }}
恢复时间: {{ $alert.EndsAt.Format "2006-01-02 15:04:05" }}
===参考信息===
{{ if gt (len $alert.Labels.instance) 0 -}}故障实例ip: {{ $alert.Labels.instance }};{{- end -}}
{{- if gt (len $alert.Labels.namespace) 0 -}}故障实例所在namespace: {{ $alert.Labels.namespace }};{{- end -}}
{{- if gt (len $alert.Labels.node) 0 -}}故障物理机ip: {{ $alert.Labels.node }};{{- end -}}
{{- if gt (len $alert.Labels.pod_name) 0 -}}故障pod名称: {{ $alert.Labels.pod_name }};{{- end }}
=====================
{{- end }}
{{- end }}
{{- end }}
```

### prometheus

#### 监控项梳理
个人需要的监控项大概分为两类：
一个是系统硬件层面的，cpu，负载，内存，磁盘这些。
另一个就是基于url的api监控。

#### 主配置文件
```yml
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
      - targets: ["localhost:9093"]

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
   - "/usr/local/prometheus/rules/alert.yml"
#这里就类似zabbix的自定义监控项及触发器。
# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"]
  - job_name: web_status
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
    #下边通过不同的instance区分了不同url的节点，这样在后边配置报警的时候，可以只配置一次，通过不同的instance区分服务。
      - targets: ['xx']
        labels:
          instance: weibo
          group: 'web'
      - targets: ['xx']
        labels:
          instance: khronos
          group: 'web'
      - targets: ['xx']
        labels:
          instance: blog
          group: 'web'
      - targets: ['xx']
        labels:
          instance: daoserver
          group: 'web'
      - targets: ['xx']
        labels:
          instance: git
          group: 'web'
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - target_label: __address__
        replacement: 127.0.0.1:9115
```

#### 监控规则
```yml
groups:
  - name: cpu.rules
    rules:
    - alert: 负载超过0.5
      expr: node_load1 > 0.5 or node_load5 > 0.5 or node_load15 > 0.5
      for: 3m
      labels:
        severity: warning
      annotations: 
        description: '{{$labels.instance}} 负载超过0.5。'
        summary: 负载超过0.5
    - alert: cpu使用率超过70%
      expr: avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance)* 100 < 30
      for: 3m
      labels:
        severity: warning
      annotations: 
        description: '{{$labels.instance}} cpu 使用率超过70%。'
        summary: cpu 使用率超过70%
  - name: mem.rules
    rules:
    - alert: 可用内存不足20% 
      expr: (node_memory_MemTotal_bytes - (node_memory_MemFree_bytes + node_memory_Buffers_bytes+node_memory_Cached_bytes ))/node_memory_MemTotal_bytes * 100 > 80 
      for: 3m
      labels:
        severity: warning
      annotations: 
        description: '{{$labels.instance}} 可用内存不足20%。'
        summary: 可用内存不足20% 
  - name: disk.rules
    rules:
    - alert: 根分区剩余不足20% 
      expr: (node_filesystem_size_bytes{mountpoint="/"} - node_filesystem_free_bytes{mountpoint="/"})/node_filesystem_size_bytes{mountpoint="/"} * 100 > 80
      for: 3m
      labels:
        severity: error 
      annotations: 
        description: '{{$labels.instance}} 根分区剩余不足20%。'
        summary: 根分区剩余不足20%
    - alert: data分区剩余不足20% 
      expr: (node_filesystem_size_bytes{mountpoint="/data"} - node_filesystem_free_bytes{mountpoint="/data"})/node_filesystem_size_bytes{mountpoint="/data"} * 100 > 80
 
      for: 3m
      labels:
        severity: error
      annotations: 
        description: '{{$labels.instance}} data分区剩余不足20%。'
        summary: data分区剩余不足20%
  - name: api.rules
    rules:
    - alert: url异常 
      expr: probe_success{job="web_status"} != 1 
      for: 1m
      labels:
        severity: critical 
      annotations: 
        description: '{{$labels.instance}} url异常。'
        summary: url异常
```

#### 一些说明
1. alert和recode
    
prometheus监控系统的的报警规则是在prometheus这个组件完成配置的。 prometheus支持2种类型的规则，记录规则和报警规则， 记录规则主要是为了简写报警规则和提高规则复用的， 报警规则才是真正去判定是否需要报警的规则。 报警规则中是可以使用记录规则的。
```yml
recode_rules.yml:
groups:
  - name: node-exporter-record
    rules:
    - expr: up{job=~"node-exporter"}
      record: node_exporter:up 
      labels: 
        desc: "节点是否在线, 在线1,不在线0"
        unit: " "
        job: "node-exporter"

alert_rules.yml:
groups:
  - name: node-exporter-alert
    rules:
    - alert: node-exporter-down
      expr: node_exporter:up == 0 
      for: 1m
      labels: 
        severity: info
      annotations: 
        summary: "instance: {{ $labels.instance }} 宕机了"  
        description: "instance: {{ $labels.instance }} \n- job: {{ $labels.job }} 关机了， 时间已经1分钟了。" 
        value: "{{ $value }}"
        instance: "{{ $labels.instance }}"
        grafana: "http://xxxxxxxx.com/d/node-exporter/node-exporter?orgId=1&var-instance={{ $labels.instance }} "
        console: "https://ecs.console.aliyun.com/#/server/{{ $labels.instanceid }}/detail?regionId=cn-beijing"
        cloudmonitor: "https://cloudmonitor.console.aliyun.com/#/hostDetail/chart/instanceId={{ $labels.instanceid }}&system=&region=cn-beijing&aliyunhost=true"
        id: "{{ $labels.instanceid }}"
        type: "aliyun_meta_ecs_info"
```
2. 报警级别
    一共有四个报警级别：
    * critical
    * error
    * warn
    * info
    高级别的报警会抑制低级别的报警，所以实际使用时候，可以根据不同级别设置报警规则。
    比如磁盘使用率60%的时候是info，70%是warn这种。
3. 各种监控项 
    监控项来源于prometheus中储存的数据，常用的监控项可以看[prometheus-监控项](https://blog.csdn.net/han949417140/article/details/112462319)文章，本质上就是PromQL，可以自己通过PromQL来设置所需要的监控项。

## 实际结果
经过大概一天的配置调试，目前整个监控系统在我的服务器上运行正常，测试了各种触发器也正常。基本上可以做到对于我单台或者少数台服务器的监控。
在异常出现后，可以通过微信接收到报警信息，基本满足前期设想。

## 结语

之所以写这篇文章也是出于个人使用考虑。网上的文章基本都限于安装然后通过grafana查看监控表盘，读下来之后对于实际整个监控系统理解还是不够深刻。
之前也写了类似的文章，但是并没有实际在生产中使用。
这次正好有机会在一个环境中实操，我觉得经验还是宝贵的，其中也遇到了一些坑，走了一些弯路，但是实际体验下来感觉还是不错，用着很舒服，后续会考虑继续优化，目前先用着看看。