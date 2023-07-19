---
title: skywalking结合alertmanager实现监控及报警
date: 2020-6-26
updated: 2020-6-27
tags:
  - alertmanager
  - skywalking
  - 监控
  - 报警
categories:
  - note
abbrlink: 4844b561
---

## 监控说明

skywalking本身自带了监控功能，可以监控服务，端点的状态，并通过webhook进行报警。

具体监控配置 [github页面](https://github.com/apache/skywalking/blob/v6.3.0/docs/en/setup/backend/backend-alarm.md) 。

根据实际需求，本文中添加了端点响应时间的监控 。



## 报警方式

skywalking可以通过配置webhook接口，向接口post一串json。格式如下：

```json
{
			"scopeId": 2,
			"scope": "SERVICE_INSTANCE",
			"name": "grp_1013-pid:33871@RedHat895252.ncl",
			"id0": 17,
			"id1": 0,
			"ruleName": "service_instance_resp_time_rule",
			"alarmMessage": "Response time of service instance grp_103-pid:33871@RedHat895252.ncl is more than 2000ms in 1 minutes of last 3 minutes",
			"startTime": 1618821437083
		}
```

alertmanager的接口可以接受报警消息，接受的json结构如下：

```json
[
    {
        "labels": {
            "alertname": " ", 
            "job": " ", 
            "env": " "
        }, 
        "annotations": {
            "description": "", 
            "summary": ""
        }
    }
]
```

两者之间的数据结构不统一，所以需要封装一个接口，用来接受skywalking的数据，并推送到alertmanager中。

高版本的skywalking已经提供直接对接企业微信机器人，顶顶机器人等webhook服务的方法，但是因为这里使用的版本较低，需要自己做数据处理。

<!--more-->

## 版本说明

软件|版本
-|-
skywalking|6.5.0
es|6.8.15
alertmanager|0.15.2

不同版本配置大同小异，某些参数可能会有变动，以官方文档为准。

## 配置过程

#### 配置alertmanager

```bash
cat alertmanager.yml #具体配置可以根据报警渠道修改，这里配置的是通过邮件服务器发送通知
```

```yml
global:
  resolve_timeout: 5m
  smtp_require_tls: false
  smtp_smarthost:   #邮箱服务器
  smtp_from:  #邮件发件人
  smtp_auth_username:  #邮箱用户
  smtp_auth_secret:  #邮箱密码
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'mail'
receivers:
- name: 'mail'
  email_configs:
  - send_resolved: true
    to: #接收人1
  - send_resolved: true
    to: #接收人2
  - send_resolved: true
    to: #接收人3
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
```

重启alertmanager后即可。

#### 配置skywalking

```bash
cd ${skywalking_dir}/config
cat alarm-settings.yml
```

```yml
rules:
  endpoint_avg_rule:
    metrics-name: endpoint_avg
    op: ">"
    threshold: 2000
    period: 10
    count: 2
    silence-period: 5
    message: Response time of endpoint {name} is more than 2000ms in 2 minutes of last 10 minutes

webhooks:
  - http://127.0.0.1:9091/
```

> 报警规则主要有以下几点：
>
> - **规则名称**。在告警信息中显示的唯一名称。必须以`_rule`结尾。
> - **度量名称**。 也是oal脚本中的度量名。只支持long,double和int类型。详情见 [所有可能的度量名称列表](https://skyapm.github.io/document-cn-translation-of-skywalking/zh/8.0.0/setup/backend/backend-alarm.html#所有可能的度量名称列表).
> - **包含 名称**。其下的实体名称都在此规则中. 请遵循[实体名称定义](https://skyapm.github.io/document-cn-translation-of-skywalking/zh/8.0.0/setup/backend/backend-alarm.html#实体名称)。
> - **排除 名称**. 以下实体名称不在此规则中. 请遵循[实体名称定义](https://skyapm.github.io/document-cn-translation-of-skywalking/zh/8.0.0/setup/backend/backend-alarm.html#实体名称).
> - **包含 名称正则表达式**.提供一个正则表达式来包含实体名称. 如果同时设置包含名称的列表和包含名称的正则表达式，则两个规则都将生效.
> - **排除 名称正则表达式**. 提供一个正则表达式来排除需要排除的名称. 如果同时设置排除的名称列表和排除名称的正则表达式，则两个规则都将生效.
> - **阈值**。阈值。 对于多个值指标，例如**percentile**，阈值是一个数组。像`value1` `value2` `value3` `value4` `value5`这样描述. 每个值可以作为度量中每个值的阈值。如果不想通过此值或某些值触发警报，则将值设置为 `-`.
>   例如在**百分比**中，`value1`是P50的阈值,且 `-，-，value3, value4, value5`的意思是，没有阈值的P50和P75百分位告警规则.
> - **操作符**。 操作符, 支持 `>`, `<`, `=`。欢迎贡献所有的操作符。
> - **周期**.。多久告警规则需要被核实一下。这是一个时间窗口，与后端部署环境时间相匹配。
> - **计数**。 在一个周期窗口中，如果**值**秒超过阈值（按周期统计），达到计数值，需要发送警报。
> - **静默时间**。在时间N中触发报警后，在**TN -> TN + period**这个阶段不告警。 默认情况下，它和**周期**一样，这意味着相同的告警（同一个度量名称拥有相同的Id）在同一个周期内只会触发一次。

配置好后。重启skywalking服务即可。

#### 配置转换程序

转换程序的功能在于，接收skywalking推送过来的消息，进行二次封装发给alertmanager，这里使用flask写了一个，可以根据实际情况进行修改

```python
import json
from flask import Flask,request
import requests

app=Flask(__name__)
@app.route("/", methods=['POST','HEAD'])
def api_all():
    messages = request.json
    if str(type(messages)) == "<class 'list'>":
        for message in messages:
            alarmMessage = message["alarmMessage"]
            name = message["name"]
            scope = message["scope"]
            json = '[{"labels":{"alertname":"sky_walking_' + name + '","job":"' + scope +'","env":"10.110.1.177"}, "annotations":{"descr
iption":"' + name + '", "summary":"' + alarmMessage + '"}}]'
            r = requests.post("http://127.0.0.1:9093/api/v1/alerts",data=json)
    else:
        message = messages
        alarmMessage = message["alarmMessage"]
        name = message["name"]
        scope = message["scope"]
        json = '[{"labels":{"alertname":"sky_walking_' + name + '","job":"' + scope +'","env":"10.110.1.177"}, "annotations":{"description":"' + name + '", "summary":"' + alarmMessage + '"}}]'
        r = requests.post("http://127.0.0.1:9093/api/v1/alerts",data=json)
    print(messages)
    return jsonify(messages)
if __name__ == '__main__':
    app.run(host='127.0.0.1',port=9091)
```

将python服务启动之后，整个报警功能搭建完毕。

