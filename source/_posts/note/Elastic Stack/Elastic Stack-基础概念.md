---
title: Elastic Stack-基础概念
tags:
  - Elastic Stack
  - elk
categories:
  - note
abbrlink: bd055b5c
date: 2021-07-04 00:00:00
updated: 2021-07-04 00:00:00
---

# Elastic Stack-基础概念

* ### 基础概念

elastic stack = elasticsearch + logstash + kibana + beats

* elasticsearch：基于java，是个开源分布式搜索引擎。它的特点是：分布式，零配置，自动发现，索引自动分片，索引副本机制，restful风格接口，多数据源自动搜索负载等。
* logstash：基于java，是一个用于收集，分析和存储日志的工具。
* kibana：局域node.js。用于汇总，分析和搜索重要数据日志。
* beats：是一款采集系统监控数据的代理agent，是在被监控服务器上以客户端形式运行的数据收集器的总称。可以直接把数据发送给elasticsearch或者通过logstash发送给elasticsearch。然后进行后续的数据分析活动。
  * packetbeat：网络数据包分析
  * filebeat：用于监控、收集服务器日志文
  * metricbeat：用于收集各项服务的指标
  * winlogbeat：用于监控，收集windows系统的日志信息

