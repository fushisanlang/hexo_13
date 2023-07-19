---
title: 基于docker安装Crawlab
date: 2017-11-13
updated: 2017-11-14
tags:
  - docker
  - Crawlab
categories:
  - note
abbrlink: b035bbb7
---
# 基于docker安装Crawlab

### 简介

基于Golang的分布式爬虫管理平台，支持多种编程语言以及多种爬虫框架.

[项目地址](https://gitee.com/tikazyq/crawlab?_from=gitee_search)

[文档地址](https://docs.crawlab.cn/zh/)

### 环境介绍

os:Ubuntu 20.04 LTS

docker:19.03.12

### 安装部署

##### 安装Docker-Compose

为了方便起见，我们用`docker-compose`的方式来部署。`docker-compose`是一个集群管理方式，可以利用名为`docker-compose.yml`的`yaml`文件来定义需要启动的容器，可以是单个，也可以（通常）是多个的。

```bash
apt install python3-pip
pip3 install docker-compose
```

安装好 `docker-compose` 后，请运行 `docker-compose ps` 来测试是否安装正常。正常的应该是显示如下内容。

```bash
Name   Command   State   Ports
------------------------------
--------------------------------
```

这是没有 Docker 容器在运行的情况，也就是空列表。如果有容器在运行，可以看到其对应的信息。

##### 安装crawlab

Crawlab的`docker-compose.yml`定义如下。

```yaml
version: '3.3'
services:
  master: 
    image: tikazyq/crawlab:latest
    container_name: master
    environment:
      # CRAWLAB_API_ADDRESS: "https://<your_api_ip>:<your_api_port>"  # backend API address 后端 API 地址. 适用于 https 或者源码部署
      CRAWLAB_SERVER_MASTER: "Y"  # whether to be master node 是否为主节点，主节点为 Y，工作节点为 N
      CRAWLAB_MONGO_HOST: "mongo"  # MongoDB host address MongoDB 的地址，在 docker compose 网络中，直接引用服务名称
      # CRAWLAB_MONGO_PORT: "27017"  # MongoDB port MongoDB 的端口
      # CRAWLAB_MONGO_DB: "crawlab_test"  # MongoDB database MongoDB 的数据库
      # CRAWLAB_MONGO_USERNAME: "username"  # MongoDB username MongoDB 的用户名
      # CRAWLAB_MONGO_PASSWORD: "password"  # MongoDB password MongoDB 的密码
      # CRAWLAB_MONGO_AUTHSOURCE: "admin"  # MongoDB auth source MongoDB 的验证源
      CRAWLAB_REDIS_ADDRESS: "redis"  # Redis host address Redis 的地址，在 docker compose 网络中，直接引用服务名称
      # CRAWLAB_REDIS_PORT: "6379"  # Redis port Redis 的端口
      # CRAWLAB_REDIS_DATABASE: "1"  # Redis database Redis 的数据库
      # CRAWLAB_REDIS_PASSWORD: "password"  # Redis password Redis 的密码
      # CRAWLAB_LOG_LEVEL: "info"  # log level 日志级别. 默认为 info
      # CRAWLAB_LOG_ISDELETEPERIODICALLY: "N"  # whether to periodically delete log files 是否周期性删除日志文件. 默认不删除
      # CRAWLAB_LOG_DELETEFREQUENCY: "@hourly"  # frequency of deleting log files 删除日志文件的频率. 默认为每小时
      # CRAWLAB_SERVER_REGISTER_TYPE: "mac"  # node register type 节点注册方式. 默认为 mac 地址，也可设置为 ip（防止 mac 地址冲突）
      # CRAWLAB_SERVER_REGISTER_IP: "127.0.0.1"  # node register ip 节点注册IP. 节点唯一识别号，只有当 CRAWLAB_SERVER_REGISTER_TYPE 为 "ip" 时才生效
      # CRAWLAB_TASK_WORKERS: 8  # number of task executors 任务执行器个数（并行执行任务数）
      # CRAWLAB_RPC_WORKERS: 16  # number of RPC workers RPC 工作协程个数
      # CRAWLAB_SERVER_LANG_NODE: "Y"  # whether to pre-install Node.js 预安装 Node.js 语言环境
      # CRAWLAB_SERVER_LANG_JAVA: "Y"  # whether to pre-install Java 预安装 Java 语言环境
      # CRAWLAB_SETTING_ALLOWREGISTER: "N"  # whether to allow user registration 是否允许用户注册
      # CRAWLAB_SETTING_ENABLETUTORIAL: "N"  # whether to enable tutorial 是否启用教程
      # CRAWLAB_NOTIFICATION_MAIL_SERVER: smtp.exmaple.com  # STMP server address STMP 服务器地址
      # CRAWLAB_NOTIFICATION_MAIL_PORT: 465  # STMP server port STMP 服务器端口
      # CRAWLAB_NOTIFICATION_MAIL_SENDEREMAIL: admin@exmaple.com  # sender email 发送者邮箱
      # CRAWLAB_NOTIFICATION_MAIL_SENDERIDENTITY: admin@exmaple.com  # sender ID 发送者 ID
      # CRAWLAB_NOTIFICATION_MAIL_SMTP_USER: username  # SMTP username SMTP 用户名
      # CRAWLAB_NOTIFICATION_MAIL_SMTP_PASSWORD: password  # SMTP password SMTP 密码
    ports:    
      - "8080:8080" # frontend port mapping 前端端口映射
    depends_on:
      - mongo
      - redis
    # volumes:
    #   - "/var/crawlab/log:/var/logs/crawlab" # log persistent 日志持久化
  worker:
    image: tikazyq/crawlab:latest
    container_name: worker
    environment:
      CRAWLAB_SERVER_MASTER: "N"
      CRAWLAB_MONGO_HOST: "mongo"
      CRAWLAB_REDIS_ADDRESS: "redis"
    depends_on:
      - mongo
      - redis
    # environment:
    #   MONGO_INITDB_ROOT_USERNAME: username
    #   MONGO_INITDB_ROOT_PASSWORD: password
    # volumes:
    #   - "/var/crawlab/log:/var/logs/crawlab" # log persistent 日志持久化
  mongo:
    image: mongo:latest
    restart: always
    # volumes:
    #   - "/opt/crawlab/mongo/data/db:/data/db"  # make data persistent 持久化
    # ports:
    #   - "27017:27017"  # expose port to host machine 暴露接口到宿主机
  redis:
    image: redis:latest
    restart: always
    # command: redis-server --requirepass "password" # set redis password 设置 Redis 密码
    # volumes:
    #   - "/opt/crawlab/redis/data:/data"  # make data persistent 持久化
    # ports:
    #   - "6379:6379"  # expose port to host machine 暴露接口到宿主机
  # splash:  # use Splash to run spiders on dynamic pages
  #   image: scrapinghub/splash
  #   container_name: splash
  #   ports:
  #     - "8050:8050"
```

这里先定义了 `master` 节点和 `worker` 节点，也就是Crawlab的主节点和工作节点。`master` 和 `worker` 依赖于 `mongo` 和 `redis` 容器，因此在启动之前会同时启动 `mongo` 和 `redis` 容器。这样就不需要单独配置 `mongo` 和`redis` 服务了，大大节省了环境配置的时间。

其中，我们设置了Redis和MongoDB的地址，分别通过 `CRAWLAB_REDIS_ADDRESS` 和 `CRAWLAB_MONGO_HOST` 参数。`CRAWLAB_SERVER_MASTER` 设置为`Y`表示启动的是主节点（该参数默认是为`N`，表示为工作节点）。`CRAWLAB_API_ADDRESS` 是前端的API地址，请将这个设置为公网能访问到主节点的地址，`8000`是API端口。环境变量配置详情请见 [配置章节](https://docs.crawlab.cn/zh/Config)，您可以根据自己的要求来进行配置。

⚠️**注意**: 在生产环境中，强烈建议您将数据库持久化，因为否则的话，一旦您的 Docker 容器发生意外导致关闭重启，您的数据将丢失。持久化的方法就是将上述 `docker-compose.yml` 模版中的关于持久化的代码取消注释就可以了。持久化的数据包括：MongoDB 数据库、Redis 数据库、日志。

安装完 `docker-compose` 和定义好 `docker-compose.yml` 后，只需要运行以下命令就可以启动Crawlab。

```bash
docker-compose up -d
```

同样，在浏览器中输入 `http://localhost:8080` 就可以看到界面。

以此方式安装的crawlab为分布式的，分为mongo/redis/master/worker四个容器。具体的架构及不同容器的功能可以在官方文档中查看。

**在实际使用中，通过修改 `docker-compose.yml`  配置文件来对整个集群进行配置，相关配置项说明已经在注释中**

**如果需要启用多个worker，可以修改配置文件，增加一个worker即可。**





### 更新/重启 Crawlab

当 Crawlab 有更新时，我们会将新的变更构建更新到新的镜像中。最新的镜像名称都是 `tikazyq/crawlab:latest`。而一个指定版本号的镜像名称为 `tikazyq/crawlab:<version>`，例如 `tikazyq/crawlab:0.4.7` 为 v0.4.7 版本对应的镜像。

如果您需要更新最新的版本的镜像，只需要执行以下代码。

```bash
# 关闭并删除 Docker 容器
docker-compose down

# 拉取最新镜像
docker pull tikazyq/crawlab:latest

# 启动 Docker 容器
docker-compose up -d
```

##### 
