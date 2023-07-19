---
title: flink+elk(1)-通过flink完成es中日志的格式化处理
date: 2023-2-10
tags:
  - flink
  - elk
  - elastic search
categories:
  - note
abbrlink: 8e7734f5
---

# flink+elk(1)-通过flink完成es中日志的格式化处理
## 背景
[使用flink完成应用日志的分类处理](https://www.fushisanlang.cn/article/430a2835.html)中说明了公司存在日志格式化等相关功能的需求。
但是在实际应用中。处于稳定性和技术型考虑，打算将前文中的项目划分成多步骤实施。
第一步就是编写一套程序，定时抽取es中的数据，对数据进行格式化处理，存入指定位置用于分析处理。


## 需求说明
本项目需要完成以下三个需求。
1. 定时读取 `es` 中指定 `index` 中的数据。
2. 将数据进行格式化。
3. 将格式化后的数据存入到指定数据源中。
## 工具选择
结合前文所说，后续此项目会被用于 `kafka` 与 `es` 之间，为了方便后续使用，本次直接使用 `python` + `pyflink` 进行开发。
其中数据获取方便，尝试使用 `pyflink` 获取 `es` 中数据时，提醒我官方的连接器只支持 `es` 作为输出源，无法作为输入源。
因为后续无需在 `es` 中获取数据，所以没有深究这里的使用方式，而是选择通过 `requests` 访问 `es` 来获取数据。


## 测试环境说明
系统版本|cpu|mem|ip|说明
-|-|-|-|-
ubuntu 22.04.1 LTS x86_64|2C|4G|10.13.13.111|flink服务器
ubuntu 22.04.1 LTS x86_64|2C|4G|10.13.13.109|es单节点服务器

软件|版本
-|-
flink|1.16.1
es|7.17.9


## 环境搭建
### 安装es
详见文档[Elasticsearch安装配置](https://www.fushisanlang.cn/article/b0625b51.html)。

## 代码编写

### 获取flink的es7连接器
```shell
wget https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch7/1.16.1/flink-sql-connector-elasticsearch7-1.16.1.jar
```

### 在代码中引用连接es7连接器
```python
es7JarPath = "file:///root/src/python/kafka/lib/flink-sql-connector-elasticsearch7-1.16.1.jar"
t_env = TableEnvironment.create(EnvironmentSettings.in_streaming_mode())
# 设置了 PyFlink 任务的默认并行度，其中 "1" 表示默认并行度为 1，
t_env.get_config().set("parallelism.default", "1")
# 添加es7支持
t_env.get_config().set("pipeline.jars", es7JarPath)
```

### 通过requests获取索引中数据总数
```python
def getIndexDataCount(esHost, es_index):
    # 获取索引中数据总数
    countUrl = "{}/{}/_count".format(esHost, es_index)
    Logger.debug("get countUrl: {}".format(countUrl))
    try:
        r = requests.get(countUrl, auth=(esUser, esPass))
        count = r.json()["count"]
    except:
        Logger.error("get count err. resp is {}.".format(r.text))
        sys.exit(1)
    else:
        Logger.info("get count is {}.".format(count))
        return count
```

### 通过size，from两个参数循环获取数据
```python
# 这种方法适用于数据量少于1w的情况。当数据量超过10000时。es默认情况下只能返回前1w条数据。如果需要用这种方式获取数据则需要调整es配置。
def getData(esHost, es_index, esUser, esPass, fromInt, size):
    searchUrl = "{}/{}/_search?from={}&size={}".format(
        esHost, es_index, fromInt, size)
    # print(searchUrl)
    Logger.debug("get searchUrl: {}".format(searchUrl))
    try:
        r = requests.get(searchUrl, auth=(esUser, esPass))
        datas = r.json()["hits"]["hits"]
    except:
        Logger.error("get datas err. resp is {}.".format(r.text))
        sys.exit(1)

```

### 通过scroll获取数据
```python
# 使用scroll进行查询，适合对实时性要求不高但是查询量大的情况。正好满足现在的需求
def getDataByScroll(esHost, es_index, esUser, esPass, scroll_id):
    if scroll_id == "":
        searchUrl = "{}/{}/_search?scroll=1m".format(esHost, es_index)
        body = {
            "size": 1000,
            "query": {
                "match_all": {
                }
            }
        }
    else:
        searchUrl = "{}/_search/scroll".format(esHost)
        body = {
            "scroll": "1m",
            "scroll_id": scroll_id
        }
    head = {"Content-Type": "application/json"}
    try:
        r = requests.post(searchUrl, auth=(esUser, esPass),
                          headers=head, data=json.dumps(body))
        datas = r.json()["hits"]["hits"]

    except:
        Logger.error("get datas err. resp is {}.".format(r.text))
        Logger.error("url is {}.".format(searchUrl))
        Logger.error("data is {}.".format(json.dumps(body)))
        sys.exit(1)
```

### 数据处理
初始数据展示如下：
```json
{
	"_index": "xxx-2023.02.10",
	"_type": "_doc",
	"_id": "BUOfOIYBro06UuEtTCoh",
	"_score": 1.0,
	"_ignored": ["message.keyword"],
	"_source": {
		"@version": "1",
		"tags": ["xxx"],
		"log": {
			"file": {
				"path": "xxx"
			},
			"flags": ["multiline"]
		},
		"input": {
			"type": "log"
		},
		"topics": "xxx",
		"prospector": {
			"type": "log"
		},
		"@timestamp": "2023-02-10T00:00:06.059Z",
		"message": "2023-02-10 08:00:00.776 [http-nio-8180-exec-22] INFO  com.enci.xxx.xxx.xxx.xxx.xxx - [TID:xxx] - UUID-xxx xxxxxxxxx",
		"offset": 599654,
		"fields": {
			"log_topic": "xxx"
		},
		"source": "/data/logs/xxx/xxx.log",
		"type": "xxx"
	}
}
```

处理数据：
```python
id = data["_id"]
log["log_tags"] = data["_source"]["tags"][0]
log["log_source"] = data["_source"]["source"]
log["log_topics"] = data["_source"]["topics"]
message = data["_source"]["message"]
messageList = message.split(" ", 7)
log["log_date"] = messageList[0]
log["log_time"] = messageList[1]
log["log_pid"] = messageList[2]
log["log_level"] = messageList[3]
log["log_class"] = messageList[5]
logStrList = messageList[7].split("-", 1)
log["log_tid"] = logStrList[0]
log["log_message"] = logStrList[1]
```

### 在pyflink中创建输出表

```python
t_env.execute_sql(
        """
        CREATE TABLE sink ( 
            id STRING,
            log_tags STRING,
            log_source STRING,
            log_topics STRING,
            log_date STRING,
            log_time STRING,
            log_pid STRING,
            log_level STRING,
            log_class STRING,
            log_tid STRING,
            log_message STRING
        ) WITH (
            'connector' = 'elasticsearch-7',
            'hosts' = '{}',
            'index' = '{}',
            'username' = '{}',
            'password' = '{}'
        );""".format(esHost, index, esUser, esPass)
    )
```

### 将数据写入es中
```python
table = tab.select(
  col('id'),
  col('data').json_value('$.log_tags', DataTypes.STRING()),
  col('data').json_value('$.log_source', DataTypes.STRING()),
  col('data').json_value('$.log_topics', DataTypes.STRING()),
  col('data').json_value('$.log_date', DataTypes.STRING()),
  col('data').json_value('$.log_time', DataTypes.STRING()),
  col('data').json_value('$.log_pid', DataTypes.STRING()),
  col('data').json_value('$.log_level', DataTypes.STRING()),
  col('data').json_value('$.log_class', DataTypes.STRING()),
  col('data').json_value('$.log_tid', DataTypes.STRING()),
  col('data').json_value('$.log_message', DataTypes.STRING())
)
# wait() 方法的作用是等待数据插入操作完成并返回结果。在执行 execute_insert 方法时，Flink 会异步地执行数据的插入操作，而 wait() 方法则会阻塞当前线程，直到数据插入操作完成。这样做的好处是可以确保在后续代码执行前，数据已经完全插入到目标位置。
table.execute_insert('sink').wait()
```

### 处理结果展示
```json
{
	"_index": "user",
	"_type": "_doc",
	"_id": "DcQ9OoYB9qtUsCb5PE-I",
	"_score": 1.0,
	"_ignored": ["log_message.keyword"],
	"_source": {
		"id": "3dK1OIYBOSDPnSFscKNl",
		"log_tags": "xxx",
		"log_source": "/data/logs/xxx/xxx.log",
		"log_topics": "xxx",
		"log_date": "2023-02-10",
		"log_time": "08:24:18.646",
		"log_pid": "[http-nio-8180-exec-52]",
		"log_level": "INFO",
		"log_class": "weixin.xxx.xxx.xxx",
		"log_tid": "[TID:xxx] ",
		"log_message": " UUID-xxx xxxxxxx"
	}
}
```

## 完整代码记录
```python
import requests
import json
import sys
from pyflink.table import (EnvironmentSettings, TableEnvironment, DataTypes)
from pyflink.table.expressions import col

import logging

# 配置日志
logFile = "/tmp/1.log"
logging.basicConfig(level=logging.INFO, filename=logFile,
                    format='%(asctime)s - %(levelname)s - %(message)s')
Logger = logging.getLogger(__name__)


# Elasticsearch 服务器地址
esHttp = "http"
esIp = ""
esPort = 9200
esHost = "{}://{}:{}".format(esHttp, esIp, esPort)


# 用户名和密码
esUser = "your_username"
esPass = "your_password"

# 查询索引
es_index = ""

# 写入索引
ouputIndex = ""
# 定义每次执行条数
size = 1000

# es7连接jar包位置
es7JarPath = "file:///.../flink-sql-connector-elasticsearch7-1.16.1.jar"


def getIndexDataCount(esHost, es_index):
    # 获取索引中数据总数
    countUrl = "{}/{}/_count".format(esHost, es_index)
    Logger.debug("get countUrl: {}".format(countUrl))
    try:
        r = requests.get(countUrl, auth=(esUser, esPass))
        count = r.json()["count"]
    except:
        Logger.error("get count err. resp is {}.".format(r.text))
        sys.exit(1)
    else:
        Logger.info("get count is {}.".format(count))
        return count


# 查询数据
# 这种方法适用于数据量少于1w的情况。当数据量超过10000时。es默认情况下只能返回前1w条数据。如果需要用这种方式获取数据则需要调整es配置。
def getData(esHost, es_index, esUser, esPass, fromInt, size):

    searchUrl = "{}/{}/_search?from={}&size={}".format(
        esHost, es_index, fromInt, size)
    # print(searchUrl)
    Logger.debug("get searchUrl: {}".format(searchUrl))
    try:
        r = requests.get(searchUrl, auth=(esUser, esPass))
        datas = r.json()["hits"]["hits"]
    except:
        Logger.error("get datas err. resp is {}.".format(r.text))
        sys.exit(1)
    else:
        dataList = []
        for data in datas:
            log = {}
            try:
                id = data["_id"]
                log["log_tags"] = data["_source"]["tags"][0]
                log["log_source"] = data["_source"]["source"]
                log["log_topics"] = data["_source"]["topics"]
                message = data["_source"]["message"]
                messageList = message.split(" ", 7)
                log["log_date"] = messageList[0]
                log["log_time"] = messageList[1]
                log["log_pid"] = messageList[2]
                log["log_level"] = messageList[3]
                log["log_class"] = messageList[5]
                logStrList = messageList[7].split("-", 1)
                log["log_tid"] = logStrList[0]
                log["log_message"] = logStrList[1]
            except Exception as e:
                Logger.error("format data err because : {}".format(e))

                Logger.error("data is .".format(data))
            else:
                dataList.append((id, str(json.dumps(log.copy()))))
        return dataList


# 使用scroll进行查询，适合对实时性要求不高但是查询量大的情况。正好满足现在的需求
def getDataByScroll(esHost, es_index, esUser, esPass, scroll_id):
    if scroll_id == "":
        searchUrl = "{}/{}/_search?scroll=1m".format(esHost, es_index)
        body = {
            "size": 1000,
            "query": {
                "match_all": {
                }
            }
        }
    else:
        searchUrl = "{}/_search/scroll".format(esHost)
        body = {
            "scroll": "1m",
            "scroll_id": scroll_id
        }
    head = {"Content-Type": "application/json"}
    try:
        r = requests.post(searchUrl, auth=(esUser, esPass),
                          headers=head, data=json.dumps(body))
        datas = r.json()["hits"]["hits"]

    except:
        Logger.error("get datas err. resp is {}.".format(r.text))
        Logger.error("url is {}.".format(searchUrl))
        Logger.error("data is {}.".format(json.dumps(body)))
        sys.exit(1)
    else:
        scrollId = r.json()["_scroll_id"]
        dataList = []
        for data in datas:
            log = {}
            try:
                id = data["_id"]
                log["log_tags"] = data["_source"]["tags"][0]
                log["log_source"] = data["_source"]["source"]
                log["log_topics"] = data["_source"]["topics"]
                message = data["_source"]["message"]
                messageList = message.split(" ", 7)
                log["log_date"] = messageList[0]
                log["log_time"] = messageList[1]
                log["log_pid"] = messageList[2]
                log["log_level"] = messageList[3]
                log["log_class"] = messageList[5]
                logStrList = messageList[7].split("-", 1)
                log["log_tid"] = logStrList[0]
                log["log_message"] = logStrList[1]
            except Exception as e:
                Logger.error("format data err because : {}".format(e))

                Logger.error("data is .".format(data))
            else:
                dataList.append((id, str(json.dumps(log.copy()))))
    return scrollId, dataList


def saveDataToEs7ByPyflink(es7JarPath, dataList, esHost, index, esUser, esPass):
    t_env = TableEnvironment.create(EnvironmentSettings.in_streaming_mode())
    # 设置了 PyFlink 任务的默认并行度，其中 "1" 表示默认并行度为 1，
    t_env.get_config().set("parallelism.default", "1")
    # 添加es7支持
    t_env.get_config().set("pipeline.jars", es7JarPath)
    # 根据dataList创建数据源
    tab = t_env.from_elements(elements=dataList, schema=['id', 'data'])
    # 创建数据输出表sink
    t_env.execute_sql(
        """
        CREATE TABLE sink ( 
            id STRING,
            log_tags STRING,
            log_source STRING,
            log_topics STRING,
            log_date STRING,
            log_time STRING,
            log_pid STRING,
            log_level STRING,
            log_class STRING,
            log_tid STRING,
            log_message STRING
        ) WITH (
            'connector' = 'elasticsearch-7',
            'hosts' = '{}',
            'index' = '{}',
            'username' = '{}',
            'password' = '{}'
        );""".format(esHost, index, esUser, esPass)
    )
    # 查询数据
    table = tab.select(
        col('id'),
        col('data').json_value('$.log_tags', DataTypes.STRING()),
        col('data').json_value('$.log_source', DataTypes.STRING()),
        col('data').json_value('$.log_topics', DataTypes.STRING()),
        col('data').json_value('$.log_date', DataTypes.STRING()),
        col('data').json_value('$.log_time', DataTypes.STRING()),
        col('data').json_value('$.log_pid', DataTypes.STRING()),
        col('data').json_value('$.log_level', DataTypes.STRING()),
        col('data').json_value('$.log_class', DataTypes.STRING()),
        col('data').json_value('$.log_tid', DataTypes.STRING()),
        col('data').json_value('$.log_message', DataTypes.STRING())
    )
    # 将数据写入sink表
    # wait() 方法的作用是等待数据插入操作完成并返回结果。在执行 execute_insert 方法时，Flink 会异步地执行数据的插入操作，而 wait() 方法则会阻塞当前线程，直到数据插入操作完成。这样做的好处是可以确保在后续代码执行前，数据已经完全插入到目标位置。
    table.execute_insert('sink').wait()


count = getIndexDataCount(esHost, es_index)
# 查询次数
searchTime = count//size
i = 0
scrollId = ""
while True:
    fromInt = i*size
    # dataList = getData(esHost,es_index,esUser, esPass,fromInt,size)
    scrollId, dataList = getDataByScroll(
        esHost, es_index, esUser, esPass, scrollId)

    if len(dataList) == 0:
        break
    try:
        saveDataToEs7ByPyflink(es7JarPath, dataList,
                               esHost, ouputIndex, esUser, esPass)
    except Exception as e:
        Logger.error("save data from {} to {} in {} err.".format(
            fromInt, fromInt+size, ouputIndex))
        Logger.error("because {}.".format(e))
    else:
        Logger.info("save data from {} to {} in {} done.".format(
            fromInt, fromInt+size, ouputIndex))
    i = i+1

Logger.info("save {} line data.exiting...".format(count))

```

## 任务启动

### 基础启动
```shell
/soft/flink-1.16.1/bin/flink run -py xxx.py
```

### 定时任务集成
可以将脚本中的 `index` 设置为执行参数。
通过 `crontab` 调用 `flink` 执行脚本。
每次执行前通过传入当天的日期选择执行的脚本完成定时化。
但是因为整个项目不可能只有一条定时任务，所以我这里打算使用其他的定时任务管理平台，暂时还没选好型，后续继续更新。