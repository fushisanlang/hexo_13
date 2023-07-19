---
title: dataX使用
date: 2018-6-2
updated: 2018-6-3
tags:
  - dataX
  - DB
categories:
  - note
abbrlink: 5585c728
---

### 说明

[dataX github](https://github.com/alibaba/DataX)

> DataX 是阿里巴巴集团内被广泛使用的离线数据同步工具/平台，实现包括 MySQL、Oracle、SqlServer、Postgre、HDFS、Hive、ADS、HBase、TableStore(OTS)、MaxCompute(ODPS)、DRDS 等各种异构数据源之间高效的数据同步功能。



### 环境需求

- Linux
- [JDK(1.8以上，推荐1.8)](http://www.oracle.com/technetwork/cn/java/javase/downloads/index.html)
- [Python(推荐Python2.6.X)](https://www.python.org/downloads/)
- [Apache Maven 3.x](https://maven.apache.org/download.cgi) (用于编译安装)



### 安装

本部分直接下载DataX工具包：[DataX下载地址](http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz)

下载后解压至本地某个目录，进入bin目录，即可运行同步作业：

```shell
cd  {YOUR_DATAX_HOME}/bin
python datax.py {YOUR_JOB.json}
```

自检脚本：
```shell
python {YOUR_DATAX_HOME}/bin/datax.py {YOUR_DATAX_HOME}/job/job.json
```

还可以使用源码编译安装，git上有详细文档，不在赘述。



### 使用

**对于不同数据库，读写参数不尽相同，可以根据git上的提示自行修改，下文为常用的部分参数**

读参数表

| 参数名   | 解释                 | 备注                                                   |
| -------- | -------------------- | ------------------------------------------------------ |
| name     | 与要读取的数据库一致 | 字符串                                                 |
| jdbcUrl  | 数据库链接           | 数组,会自动选择一个合法的链接,可以填写连接附件控制信息 |
| username | 用户名               | 字符串，数据库的用户名                                 |
| password | 密码                 | 字符串，数据库的密码                                   |
| table    | 要同步的表名         | 数组，需保证表结构一致                                 |
| column   | 要同步的列名         | 数组                                                   |
| where    | 选取的条件           | 字符串                                                 |
| querySql | 自定义查询语句       | 会自动忽略上述的同步条件                               |

 写参数表

| 参数名    | 解释                   | 备注                                           |
| --------- | ---------------------- | ---------------------------------------------- |
| name      | 与要读取的数据库一致   | 字符串                                         |
| jdbcUrl   | 数据库链接             | 字符串,不和writer一样,可以填写连接附件控制信息 |
| username  | 用户名                 | 字符串，数据库的用户名                         |
| password  | 密码                   | 字符串，数据库的密码                           |
| table     | 要同步的表名           | 数组，需保证表结构一致                         |
| column    | 要同步的列名           | 列名可以不对应，但是类型和总的个数要一致       |
| preSql    | 写入前执行的语句       | 数组，比如清空表等                             |
| postSql   | 写入后执行的语句       | 数组                                           |
| writeMode | 写入方式，默认为insert | insert/replace/update                          |





