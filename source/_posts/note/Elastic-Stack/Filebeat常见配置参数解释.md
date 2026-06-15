---
title: Filebeat常见配置参数解释
date: 2026-06-15
tags:
  - filebeat
  - elastic
  - 日志收集
categories:
  - note
---

Filebeat 配置参数详细说明，涵盖 input、prospector、output 各配置段。

<!--more-->

## 1. input 配置段（prospector）

```yaml
filebeat.prospectors:
  - input_type: log          # log: 从日志文件读取每一行; stdin: 从标准输入读取
    paths:
      - /var/log/*.log        # 日志文件路径列表，可用通配符，不递归
    encoding: plain           # 编码，默认 plain
    include_lines: ['^ERR', '^WARN']   # 匹配行，输出匹配行；与多行同时指定时优先过滤
    exclude_lines: ['^DBG']   # 排除行
    ignore_older: 5m          # 排除更改时间超过定义的文件
    document_type: log         # 会被添加到 ES 存储的 type 字段
    scan_frequency: 10s       # prospector 扫描新文件的时间间隔
    max_bytes: 10485760       # 单文件最大收集字节数（默认10MB），需与日志轮转一致
```

### 多行匹配

```yaml
multiline.pattern: '^['       # 多行匹配模式，正则表达式
multiline.negate: false        # 模式是否取反
multiline.match: after         # 多行内容添加到匹配行之后还是之前
multiline.max_lines: 500       # 单一多行聚合的最大行数
multiline.timeout: 5s          # 多行匹配超时时间
```

## 2. 通用配置段

```yaml
name: filebeat               # 发送端标识
tags: ["service-X"]          # 添加 tags，用于过滤
fields:                      # 添加额外字段
  service: myservice
fields_under_root: false     # 额外字段是否作为根字段
```

## 3. output.elasticsearch

```yaml
output.elasticsearch:
  hosts: ["localhost:9200"]
  index: "filebeat-%{+yyyy.MM.dd}"
  username: "elastic"
  password: "password"
  ssl.certificate_authorities: ["/path/to/ca.crt"]
  ssl.certificate: "/path/to/client.crt"
  ssl.key: "/path/to/client.key"
```

## 4. output.logstash

```yaml
output.logstash:
  hosts: ["localhost:5044"]
  loadbalance: true           # 启用负载均衡
  ssl.enabled: true
  ssl.certificate_authorities: ["/path/to/ca.crt"]
```

## 5. output.redis

```yaml
output.redis:
  hosts: ["localhost"]
  port: 6379
  password: "password"
  db: 0
  key: "filebeat"
```

## 6. Paths 配置段

```yaml
filebeat.config.paths:
  prospector: /etc/filebeat/conf.d/*.yml
  modules: /etc/filebeat/modules.d/*.yml
```

## 7. logging 配置段

```yaml
logging.level: info           # 日志级别
logging.to_files: true        # 输出到文件
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7                # 保留日志文件数
  permissions: 0644
```

## 常用完整配置示例

```yaml
filebeat.prospectors:
  - paths:
      - /var/log/nginx/*.log
    input_type: log
    document_type: nginx-access
    multiline.pattern: '^\d{4}-\d{2}-\d{2}'
    multiline.negate: true
    multiline.match: after

output.logstash:
  hosts: ["192.168.1.10:5044"]
  loadbalance: true
```
