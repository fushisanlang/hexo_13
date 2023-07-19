---
title: docker调整时区
tags:
  - docker
  - timezone
categories:
  - note
abbrlink: e555bb4
date: 2022-04-18 00:00:00
---
# docker调整时区

### 简介

通过运行的服务，发现定时任务执行的时间与预期时间相差8小时，猜测是时区原因。
对服务的定时任务进行了重新配置，更改了时区也不生效，猜测是docker容器的时区异常。

### 错误配置一

在网上找了一个配置docker时区的方法，在运行的时候挂在本地时区配置文件。
```shell
 -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro
```
结果发现启动后有报错。
```
tzlocal.utils.ZoneInfoNotFoundError: 'Multiple conflicting time zone configurations found:\n/etc/timezone: Asia/Shanghai\n/etc/localtime is a symlink to: UCT\nFix the configuration, or set the time zone in a TZ environment variable.\n'
```

### 正确配置

通过传递环境变量的方式进行了配置。
```shell
-e TZ=Asia/Shanghai 
```

实测可用。

### 后续

错误配置一应该是因为平台系统与docker内部系统不是同一个linux发行版。
我是通过Centos平台运行的容器。容器经过多次封装找不到基础镜像是哪个发行版了，只能看见是Debian系。

后续使用时，可以直接在dockerfile里加入环境变量，就不需要在生成容器是添加参数了。