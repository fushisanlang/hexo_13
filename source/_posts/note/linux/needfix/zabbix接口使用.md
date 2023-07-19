---
title: zabbix接口使用
date: 2020-6-21
updated: 2020-6-22
categories:
  - note
abbrlink: de390be8
---
## zabbix接口使用


URL 192.168.1.231/zabbix/api_jsonrpc.php


1、认证

```json
POST：
{
"jsonrpc": "2.0",
"method": "user.login",
"params": {
"user": "Admin",
"password": "zabbix"
},
"id": 1,
"auth": null
}

RESULT：
{
    "jsonrpc": "2.0",
    "result": "426bfd06b14b3d020f26645b38d0ad35",
    "id": 1
}
```

2、查询所有主机ID及接口

```json
POST：
{
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
        "output": [
            "hostid",
            "host"
        ],
        "selectInterfaces": [
            "interfaceid",
            "ip"
        ]
    },
    "id": 1,
    "auth": "426bfd06b14b3d020f26645b38d0ad35"
}

RESULT：
{
    "jsonrpc": "2.0",
    "result": [
        {
            "hostid": "10084",
            "host": "Zabbix server",
            "interfaces": [
                {
                    "interfaceid": "1",
                    "ip": "127.0.0.1"
                }
            ]
        },   
        {
            "hostid": "10385",
            "host": "APP-JFPT-192.168.1.178",
            "interfaces": [
                {
                    "interfaceid": "246",
                    "ip": "192.168.1.178"
                }
            ]
        }
    ],
    "id": 1
}
```


3、查询主机监控项
```json
{
	"jsonrpc": "2.0",
	"method": "item.get",
	"params": {
		"output": "extend",
		"hostids": "10385",
		"sortfield": "name"
	},
	"auth": "426bfd06b14b3d020f26645b38d0ad35",
	"id": 1
}
```

