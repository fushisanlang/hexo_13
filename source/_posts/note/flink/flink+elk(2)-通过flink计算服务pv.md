---
title: flink+elk(2)-通过flink计算服务pv
date: 2023-2-16
tags:
  - flink
  - elk
  - elastic search
categories:
  - note
abbrlink: '91182204'
---

# flink+elk(2)-通过flink计算服务pv
## 背景
[通过flink完成es中日志的格式化处理](https://www.fushisanlang.cn/article/8e7734f5.html)中说已经将 `filebeat` 抓取的日志通过 `flink` 进行了格式化。
但是在这篇文章中，使用的还是类似`批处理`的思路，通过`定时任务`加 `flink` 的方式做处理。
`flink` 更为出名的是他的`流计算`功能。
本文将依托于 `flink` 的`流计算`功能，来演示如何实时计算`应用`的 `pv`，并通过 `kibana` 及 `grafana` 实时展示。


## 需求说明
1. 实时通过 `Kafka` 读取日志数据。
2. 将读取到的数据格式化，并放入 `kafka` 的另一个 `topic` 中。
3. 读取格式化后的日志，实时计算 `pv` 。
4. 将 `pv` 数据写入 `es数据库` 。
5. 通过展示软件进行展示。


## 测试环境说明
系统版本|cpu|mem|ip|说明
-|-|-|-|-
ubuntu 22.04.1 LTS x86_64|2C|4G|10.13.13.111|flink服务器
ubuntu 22.04.1 LTS x86_64|2C|4G|10.13.13.111|zookeeper单节点服务器
ubuntu 22.04.1 LTS x86_64|2C|4G|10.13.13.111|kafka单节点服务器
ubuntu 22.04.1 LTS x86_64|2C|4G|10.13.13.109|es单节点服务器
ubuntu 22.04.1 LTS x86_64|2C|4G|10.13.13.109|kibana服务器
ubuntu 22.04.1 LTS x86_64|2C|4G|10.13.13.109|filebeat服务器
ubuntu 22.04.1 LTS x86_64|2C|4G|10.13.13.109|grafana服务器

软件|版本
-|-
flink|1.16.1
es|7.17.9
kibana|7.17.9
filebeat|8.5.0

## 环境搭建
### 安装es
详见文档[Elasticsearch安装配置](https://www.fushisanlang.cn/article/b0625b51.html)。
### 安装filebeat，kibana，grafana
根据官网给定的安装方式进行安装。
### 安装zk，kafka，flink
详见文档[使用flink完成应用日志的分类处理](https://www.fushisanlang.cn/article/430a2835.html)中的安装部分。

## 系统配置
### filebeat配置
在实际应用中，应用日志并不一定是每行代表一条日志。比如 `java` 的`堆栈日志`会有多行。
如果直接使用 `filebeat` 进行按行收集，就会出现异常。
这时可以 `multiline` 配置。可以通过[multiline官方文档](https://www.elastic.co/guide/en/beats/filebeat/current/multiline-examples.html#:~:text=The%20files%20harvested%20by%20Filebeat%20may%20contain%20messages,which%20lines%20are%20part%20of%20a%20single%20event.)学习相关配置方法。
我这里使用的配置如下：
```yml
filebeat.inputs:
- type: log 
  id: my-filestream-id
  enabled: true
  paths:
    - /data/logs/*.log
  multiline.type: pattern   #新增的multiline配置
  multiline.pattern: '^[0-9]{4}-[0-9]{2}-[0-9]{2}'
  multiline.negate: true
  multiline.match: after
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
setup.template.settings:
  index.number_of_shards: 1
setup.kibana:
output.kafka:
  hosts: ["10.13.13.111:9092"]
  topic: 'log_from_ecs'
processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~
  - add_docker_metadata: ~
  - add_kubernetes_metadata: ~
```

### 其余配置
其余服务并未新增配置，可以按照前文中的方法进行配置。

## 流程建立
### step 1. kafka -> kafka
#### 说明
本流程主要完成以下操作：
* 从 `kafka` 的 `log_from_ecs` 队列中读取数据。这个队列数据来自 `filebeat`
* 对数据进行 `json化`，提取有用的数据字段
* 剔除无用数据
* 将处理好的数据放入 `kafka` 的 `log_format_json` 队列
#### 具体实现
```python
from pyflink.table import (EnvironmentSettings, TableEnvironment, DataTypes)
from pyflink.table.expressions import col

env_settings = EnvironmentSettings.in_streaming_mode()
t_env = TableEnvironment.create(env_settings)
t_env.get_config().set("parallelism.default", "1")
t_env.get_config().set("pipeline.jars", "file:///root/src/python/kafka/lib/flink-sql-connector-kafka-1.16.1.jar")

# 创建source源表
t_env.execute_sql("""
    create table source ( 
        log STRING ,
        message STRING,
        host STRING
    ) with ( 
        'connector' = 'kafka',
        'topic' = '{}',
        'properties.bootstrap.servers' = '{}',
        'properties.group.id' = '{}',
        'scan.startup.mode' = 'earliest-offset',
        'format' = 'json' 
    )""".format("log_from_ecs","10.13.13.111:9092","log_from_ecs"))

# 源表数据切割整理-这里的处理逻辑就是文本切割，将log_from_ecs中的message字段做切割，分成需要的字段
table = t_env.from_path("source").select(
    col("log").json_value('$.file.path',DataTypes.STRING()).alias("logFrom"),
    col("host").json_value('$.ip.[0]',DataTypes.STRING()).alias("escIP"),
    col('message').split_index(" - [",0).substring(0,23).to_timestamp.alias("timeSTR"),    
    col('message').split_index(" - [",0).split_index(" ",2).trim("[|]").alias("pidSTR"),
    col('message').split_index(" - [",0).split_index(" ",3).alias("levelSTR"),
    col('message').split_index(" - [",0).split_index(" ",5).alias("classSTR"),
    col('message').split_index(" - [",1).split_index("] - ",0).trim("TID:").alias("tidSTR"),
    col('message').split_index(" - [",1).split_index("] - ",1).alias("logSTR"),
)

# 数据清洗-略过没有tid，即tid=N/A的日志。这里的tid是业务的traceID，这里是一个简单的清洗逻辑。实际可以根据实际情况做调整
tableWithTid = table.filter(col('tidSTR')  !='N/A')

# 创建输出表
t_env.execute_sql("""
    create table tableWithTid ( 
        logFrom STRING,
        ipSTR STRING,
        timeSTR TIMESTAMP(3)   ,
        pidSTR STRING,
        levelSTR STRING,
        classSTR STRING,
        tidSTR STRING,
        logSTR STRING
     ) with ( 
        'connector' = 'kafka',
        'topic' = '{}',
        'properties.bootstrap.servers' = '{}',
        'properties.group.id' = '{}',
        'format' = 'json' 
    )""".format("log_format_json","10.13.13.111:9092","log_format_json"))

# 写入数据
tableWithTid.execute_insert('tableWithTid').wait()
```

### step 2. kafka -> es
#### 说明
本流程主要完成以下操作：
* 从 `kafka` 的 `log_format_json`队列中读取数据。这个队列数据来自前一步中 `json化` 过的日志数据
* 注意 `WATERMARK FOR timeSTR AS timeSTR ` 这个用法。是将 `timeSTR `作为`操作时间`，这里涉及到 `flink` 中 `window` 的`时间属性`。可以通过 `WATERMARK FOR user_action_time AS user_action_time - INTERVAL '5' SECOND ` 这种表述方法。将`数据中的时间 -5s `作为 `操作时间`。这个根据实际场景调整
* 将数据导入 `source` 表
* 通过 `window` 对表进行计算。这里是通过计算 `日志条数` 来统计 `pv`，根据实际情况调整 `sql`
* 需要注意这里因为展示结果时需要一个 `时间字段` ，但是直接使用 `TIMESTAMP(3)` 写入 `es `时生成的是 `text` 字段，无法作为时间字段使用。这里需要注意，这个字段的类型在 `Elasticsearch` 中，时间戳必须是 `ISO8601格式的UTC时间`。数字格式的时间戳是不可以的。~~所以通过CAST函数将时间字段转成了string，又通过UNIX_TIMESTAMP函数转成了时间戳，并将结果作为bigint类型存入了es中。~~
* 所以在查询时用了 `DATE_FORMAT` 函数做了类型转换。转换后虽然在 `sink` 表中是 `string` 类型，但是在 `es` 中存储就成了 `date` 类型
* 将数据写入 `pv` 表中
#### 具体实现
```python
from pyflink.table import EnvironmentSettings, TableEnvironment
env_settings = EnvironmentSettings.in_streaming_mode()
t_env = TableEnvironment.create(env_settings)
t_env.get_config().set("parallelism.default", "1")
t_env.get_config().set("pipeline.jars", "file:///root/src/python/kafka/lib/flink-sql-connector-elasticsearch7-1.16.1.jar;file:///root/src/python/kafka/lib/flink-sql-connector-kafka-1.16.1.jar")

# 创建源表 source
t_env.execute_sql("""
    create table source ( 
        logFrom STRING,
        ipSTR STRING,
        timeSTR TIMESTAMP(3),
        pidSTR STRING,
        levelSTR STRING,
        classSTR STRING,
        tidSTR STRING,
        logSTR STRING,
        WATERMARK FOR timeSTR AS timeSTR  
    ) with ( 
        'connector' = 'kafka',
        'topic' = '{}',
        'properties.bootstrap.servers' = '{}',
        'properties.group.id' = '{}',
        'scan.startup.mode' = 'earliest-offset',
        'format' = 'json' 
    )""".format("log_format_json","10.13.13.111:9092","log_format_json"))


# 创建输出表
t_env.execute_sql("""
    create table pv ( 
        timeSTR STRING,
        pv BIGINT
    ) with ( 
        'connector' = 'elasticsearch-7',
        'hosts' = '{}',
        'index' = '{}',
        'username' = '{}',
        'password' = '{}',
        'format'='json',
         'json.fail-on-missing-field' = 'false',
 'json.ignore-parse-errors' = 'true'
    );""".format("http://10.13.13.109:9200", "pv", "esUser", "esPass"))
# 写入数据
t_env.sql_query("""
    SELECT 
    DATE_FORMAT(TUMBLE_START(timeSTR, INTERVAL '1' MINUTE), 'yyyy-MM-dd''T''HH:mm:ss''Z''') AS times,
        COUNT(*) AS cnt 
    FROM 
        source 
    GROUP BY 
        TUMBLE(timeSTR, INTERVAL '1' MINUTE)
    """).execute_insert("pv").wait()


```

## 实时展示
经过上述的处理，在 `es` 中会生成一个名为 `pv` 的 `index` 。
它包含两个字段，`long` 类型的 `pv` 和 `date` 类型的 `timeSTR`。示例如下：
```json
"_source": {
    "timeSTR": "2023-02-15T00:00:00Z",    
    "pv": 12
}
```
### kibana展示
拿到上述数据后，可以在 `kibana` 中根据 `pv` 建立一个`索引模式`。
~~这里需要注意，因为 `timeSTR` 的类型是 `long` ，需要新建一个字段来将其转变成 `date` 类型用于数据展示。
通过添加字段按钮添加字段，类型选择 `date` ，设置值为 `emit(doc['timeSTR'].value*1000)` 。这里是 `kibana` 的`自定义字段`功能，之前的`脚本字段`将在后续版本中丢弃，所以不建议继续使用。官方文档链接为[managing-index-patterns](https://www.elastic.co/guide/en/kibana/7.17/managing-index-patterns.html#runtime-fields)。~~
经过上述操作，我们就有了`时间字段`和对应的 `pv` 值，后续可以在 `dashboard` 中添加相应图示。

### grafana展示
首先需要添加一个`数据源`。
在添加 `es 数据源` 时需要注意，要在`数据源`的 `Time field name` 里添加 `时间字段` 的名称。
这里的时间字段定义也是 `ISO8601格式的UTC时间`
我们这里填写 `timeSTR` 。
然后添加 `dashboard`，添加 `panel`。
这里将 `x轴` 数据设置为 `pv` 的`最大值`。因为只有一个数据，所以这里填写`最大值`、`最小值`、`平均值`都可以。
`y轴`数据选择 `dateHistogram` ，然后选择 `timeSTR`。
这样一个图表就做好了。