---
title: centos7部署skywalking
date: 2017-8-17
updated: 2017-8-18
tags:
  - nginx
  - skywalking
categories:
  - note
abbrlink: c82222f3
---
##版本介绍
软件|版本
-|-
os|CentOS Linux release 7.8.2003 (Core)
centos7部署skywalking|8.3.0
es|7.8
kibana|7.8
jdk|openjdk version "1.8.0_282"


##安装es
相关笔记[Elasticsearch安装配置](https://www.fushisanlang.cn/2021/02/09/note/Elastic%20Stack/Elasticsearch%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AE/)

##安装skywalking
```shell
yum install java java-devel #skywalking是java项目，需要java环境，可以使用其他方法安装jdk
mkdir /soft
cd /soft
wget https://archive.apache.org/dist/skywalking/8.3.0/apache-skywalking-apm-es7-8.3.0.tar.gz
tar xf apache-skywalking-apm-es7-8.3.0.tar.gz
cp -pr apache-skywalking-apm-bin-es7 /usr/local/skywalking
cd /usr/local/skywalking
bin/start.sh

#等待服务启动后即可通过 ip:8080 访问到web页面
```

##配置skywalking储存库
```shell
#skywalking默认使用h2进行数据存储，因为数据量较大，所以打算通过es来存储数据
cd /usr/local/skywalking/config
vim application.yml
    #修改storage的相关配置
    selector: elasticsearch7
    #修改storage中elasticsearch7的相关配置
    nameSpace: ${SW_NAMESPACE:"skywalking"}
    clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:172.19.32.29:9200}
    protocol: ${SW_STORAGE_ES_HTTP_PROTOCOL:"http"}
    trustStorePath: ${SW_STORAGE_ES_SSL_JKS_PATH:""}
    trustStorePass: ${SW_STORAGE_ES_SSL_JKS_PASS:""}
    dayStep: ${SW_STORAGE_DAY_STEP:1} # Represent the number of days in the one minute/hour/day index.
    indexShardsNumber: ${SW_STORAGE_ES_INDEX_SHARDS_NUMBER:1} # Shard number of new indexes
    indexReplicasNumber: ${SW_STORAGE_ES_INDEX_REPLICAS_NUMBER:1} # Replicas number of new indexes
    # Super data set has been defined in the codes, such as trace segments.The following 3 config would be improve es performance when storage super size data in es.
    superDatasetDayStep: ${SW_SUPERDATASET_STORAGE_DAY_STEP:-1} # Represent the number of days in the super size dataset record index, the default value is the same as dayStep when the value is less than 0
    superDatasetIndexShardsFactor: ${SW_STORAGE_ES_SUPER_DATASET_INDEX_SHARDS_FACTOR:5} #  This factor provides more shards for the super data set, shards number = indexShardsNumber * superDatasetIndexShardsFactor. Also, this factor effects Zipkin and Jaeger traces.
    superDatasetIndexReplicasNumber: ${SW_STORAGE_ES_SUPER_DATASET_INDEX_REPLICAS_NUMBER:0} # Represent the replicas number in the super size dataset record index, the default value is 0.
    user: ${SW_ES_USER:"elastic"}
    password: ${SW_ES_PASSWORD:"elk123"}
    secretsManagementFile: ${SW_ES_SECRETS_MANAGEMENT_FILE:""} # Secrets management file in the properties format includes the username, password, which are managed by 3rd party tool.
    bulkActions: ${SW_STORAGE_ES_BULK_ACTIONS:1000} # Execute the async bulk record data every ${SW_STORAGE_ES_BULK_ACTIONS} requests
    syncBulkActions: ${SW_STORAGE_ES_SYNC_BULK_ACTIONS:50000} # Execute the sync bulk metrics data every ${SW_STORAGE_ES_SYNC_BULK_ACTIONS} requests
    flushInterval: ${SW_STORAGE_ES_FLUSH_INTERVAL:10} # flush the bulk every 10 seconds whatever the number of requests
    concurrentRequests: ${SW_STORAGE_ES_CONCURRENT_REQUESTS:2} # the number of concurrent requests
    resultWindowMaxSize: ${SW_STORAGE_ES_QUERY_MAX_WINDOW_SIZE:10000}
    metadataQueryMaxSize: ${SW_STORAGE_ES_QUERY_MAX_SIZE:5000}
    segmentQueryMaxSize: ${SW_STORAGE_ES_QUERY_SEGMENT_SIZE:200}
    profileTaskQueryMaxSize: ${SW_STORAGE_ES_QUERY_PROFILE_TASK_SIZE:200}
    advanced: ${SW_STORAGE_ES_ADVANCED:""}

#关停服务后重启即可
```

## 配置java使用skywalking-agent
```shell
cd /usr/local/skywalking/agent/config
vim agent.config

	#修改如下信息：
	agent.namespace=
	agent.service_name=
	collector.backend_service=

#之后将修改后的整个agent打包，放到相应的java服务路径
#通过添加javaagent参数启动java服务
java -javaagent:agent/skywalking-agent.jar -jar Example-1.0.1.jar #启动命令示例
```