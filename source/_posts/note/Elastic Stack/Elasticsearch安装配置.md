---
title: Elasticsearch安装配置
date: 2020-2-12
updated: 2020-2-13
tags:
  - Elasticsearch
  - elk
categories:
  - note
abbrlink: b0625b51
---
# Elasticsearch安装配置

* 环境说明


|软件名|版本|
|:-:|:-:|
|rhel|7.4 x86_64|
|elasticsearch|7.3.2 x86_64|

* 安装

配置官网yum源，通过 `yum` 安装即可。

或者下载源码后解压即可使用。

* 安装后配置

elasticsearch不能通过root用户调用，如果通过源码方式安装，需要创建一个非root用户。

`yum` 方式安装后，会自动创建 `elasticsearch` 用户。

以下均已yum安装为例。

安装后，需要修改系统最大文件数，以及进程数。

```shell
vim /etc/security/limits.d/20-nproc.conf 
	*          soft    nproc     4096
	root       soft    nproc     unlimited

vim /etc/security/limits.conf
	* soft nofile 65536
	* hard nofile 131072
	* soft nproc 2048
	* hard nproc 4096

vi /etc/sysctl.conf
	vm.max_map_count=655360

sysctl -p
```

之后配置elasticsearch

```shell
cd /etc/elasticsearch

#修改jvm配置。避免测试环境资源不够导致无法启动服务
vim jvm.options
	-Xms128m
	-Xmx128m

vim elasticsearch.yml 
	cluster.name: #集群名称
	node.name: #节点名称
	path.data: #数据存储路径
	path.logs: #日志存储路径
	network.host: 0.0.0.0 #端口的bind address。可以直接改成0.0.0.0 。需要注意，这里如果不配置成	127.0.0.1或者localhost。es会默认把环境当做生产环境。所以需要更改上边的jvm参数以确保服务正常启动。
	http.port: #访问的端口
	discovery.seed_hosts: #集群的主机地址，配置后集群的主机之间可以自动发现。
	# the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured。这三个配置必须配置一个，否则会启动失败。

#文件内容总览
grep -Ev '#' elasticsearch.yml 
cluster.name: 13-es
node.name: 13-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: ["192.168.6.133"]
```

* 启动与验证

```shell
systemctl start elasticsearch.service

#访问9200端口会得到类似的json。启动时间可能会比较久。
curl -XGET "127.0.0.1:9200"
    {
      "name" : "13-1",
      "cluster_name" : "13-es",
      "cluster_uuid" : "_na_",
      "version" : {
        "number" : "7.3.2",
        "build_flavor" : "default",
        "build_type" : "rpm",
        "build_hash" : "1c1faf1",
        "build_date" : "2019-09-06T14:40:30.409026Z",
        "build_snapshot" : false,
        "lucene_version" : "8.1.0",
        "minimum_wire_compatibility_version" : "6.8.0",
        "minimum_index_compatibility_version" : "6.0.0-beta1"
      },
      "tagline" : "You Know, for Search"
    }
```

