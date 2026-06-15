---
title: ElasticSearch设置用户名密码访问
date: 2026-06-15
tags:
  - elasticsearch
  - 安全
  - xpack
categories:
  - note
---

ElasticSearch 7.3.1 设置用户名密码访问的步骤。

<!--more-->

## 1. 开启 x-pack 验证

修改 `config` 目录下面的 `elasticsearch.yml` 文件，添加如下内容，并重启：

```yaml
xpack.security.enabled: true
xpack.license.self_generated.type: basic
xpack.security.transport.ssl.enabled: true
```

## 2. 设置用户名和密码

执行以下命令，为 4 个用户分别设置密码：elastic, kibana, logstash_system, beats_system

```bash
bin/elasticsearch-setup-passwords interactive
```

需要为每个用户输入密码（至少6位）。

## 3. 修改密码

```bash
curl -H "Content-Type:application/json" \
  -XPOST -u elastic 'http://127.0.0.1:9200/_xpack/security/user/elastic/_password' \
  -d '{ "password" : "123456" }'
```
