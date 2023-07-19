---
title: datax-web部署
date: 2016-12-8
updated: 2016-12-9
categories:
  - note
abbrlink: be206806
---
# datax-web部署

[github地址](https://github.com/WeiYe-Jing/datax-web/blob/master/doc/datax-web/datax-web-deploy.md)

### 部署环境说明

* MySQL (5.5+) 必选，对应客户端可以选装, Linux服务上若安装mysql的客户端可以通过部署脚本快速初始化数据库
* JDK (1.8.0_xxx) 必选
* DataX 必选
* Python (2.x) (支持Python3需要修改替换datax/bin下面的三个python文件，替换文件在doc/datax-web/datax-python3下) 必选，主要用于调度执行底层DataX的启动脚本，默认的方式是以Java子进程方式执行DataX，用户可以选择以Python方式来做自定义的改造



### 部署说明

##### 部署datax

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



##### 部署datax-web

下载官方提供的版本tar版本包 :  `datax-web-2.1.2.tar.gz`
[百度网盘地址](https://pan.baidu.com/s/13yoqhGpD00I82K4lOYtQhg) 提取码：cpsk

```shell
mkdir -p /data/datax
tar xf datax-web-2.1.2.tar.gz -C /data/datax
cd /data/datax/datax-web-2.1.2

bin/install.sh #如果本机有mysql客户端，会在安装时提示配置mysql。本文档默认本机没有mysql客户端。

#配置数据库
vim modules/datax-admin/conf/bootstrap.properties
#Database，配置数据库信息
DB_HOST=1.1.1.1
DB_PORT=3306
DB_USERNAME=DB_USERNAME
DB_PASSWORD=DB_PASSWORD!@#
DB_DATABASE=DB_DATABASE

#配置datax.py
vim modules/datax-executor/bin/env.properties
PYTHON_PATH=/data/datax/datax/bin/datax.py #配置datax.py脚本的位置，否则web无法执行服务

bin/start-all.sh #启动服务

jps #可以通过jps命令查看服务启动状态。
#在Linux环境下使用JPS命令，查看是否出现DataXAdminApplication和DataXExecutorApplication进程，如果存在这表示项目运行成功

#如果项目启动失败，请检查启动日志：modules/datax-admin/bin/console.out或者modules/datax-executor/bin/console.out
```



### 集群部署方法

修改modules/datax-executor/conf/application.yml文件下admin.addresses地址。 为了方便单机版部署，项目目前没有将ip部分配置到env.properties，部署多节点时可以将整个地址作为变量配置到env文件。

将官方提供的tar包或者编译打包的tar包上传到服务节点，按照步骤5中介绍的方式单一地启动某一模块服务即可。例如执行器需要部署多个节点，仅需启动执行器项目，执行 `./bin/start.sh -m datax-executor`

调度中心、执行器支持集群部署，提升调度系统容灾和可用性。


* 1.调度中心集群：
  
    DB配置保持一致；
    
    集群机器时钟保持一致（单机集群忽视）；
    
* 2.执行器集群:

    执行器回调地址(admin.addresses）需要保持一致；执行器根据该配置进行执行器自动注册等操作。
    
    同一个执行器集群内AppName（executor.appname）需要保持一致；调度中心根据该配置动态发现不同集群的在线执行器列表。
