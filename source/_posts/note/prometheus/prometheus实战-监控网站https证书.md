---
title: prometheus实战-监控网站https证书
tags:
  - prometheus
  - 监控
  - 部署实录
  - https证书
categories:
  - note
abbrlink: '4123e981'
date: 2022-04-18 00:00:00
---

### 前言
通过之前[监控个人阿里云服务器](https://www.fushisanlang.cn/article/5caf4d1f.html) 的配置，对服务器和服务进行了需要的监控。
后续发现还缺少ssl证书的到期监控。

因为域名和证书都是从阿里购买的，以前会有到期预警，但是这次不知道是我忽视了还是他没发，总之https证书到期了，但是我不知道。
恰巧我的小工具用的都是这个域名，为了确保服务稳定，决定使用 blackbox_exporter 的证书监控功能对自己的服务域名证书加个监控。

### 配置
blackbox_exporter本身不需要继续配置，延续之前的配置即可。
在prometheus中，添加一条报警规则。

```yml
 - name: ca.rules
    rules:
    - alert: ca证书即将过期
      expr: (probe_ssl_earliest_cert_expiry -time())/24/60/60 < 30  
      for: 1m
      labels:
        severity: critical 
      annotations: 
        description: '{{$labels.instance}} 证书即将过期。'
        summary: 证书即将过期 
```

这里probe_ssl_earliest_cert_expiry是到期时间的时间戳，time()是当前时间戳。
(probe_ssl_earliest_cert_expiry -time())/24/60/60 < 30  即为到期时间小于30天。
对所有配置了监控的域名，会自动计算到期时间，异常就会报警。

### 后续
经过配置之后，监控正常。
经此，也又一次告诉我们，所有的监控都不应该只有一个纬度，只有一个途径。
对于监控，要尽量做到万无一失才好。


