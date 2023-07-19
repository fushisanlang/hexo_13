---
title: harbor 的部署与使用
tags:
  - docker
  - harbor
categories:
  - note
abbrlink: b68417f1
date: 2022-05-10 00:00:00
---
# 背景

因为内网的特殊环境，经常没有公网权限，而且许多公司内部的镜像不宜放入公网中，所以公司内部经常会自建docker的镜像仓库。
这样不仅可以保证镜像安全，也能节省公网流量。
常见的镜像仓库有两个，一个是registry，另一个是开源项目 harbor。


[registry 的部署与使用](https://www.fushisanlang.cn/article/fff5620d.html) 在这里。

## 部署
### 安装docker-compose

```shell
yum install docker-compose
```

### 安装habor

1. 配置docker可以通过http访问
[配置docker可以通过http访问](https://www.fushisanlang.cn/article/fff5620d.html#%E4%BF%AE%E6%94%B9-docker-%E5%8F%AF%E4%BB%A5%E9%80%9A%E8%BF%87-http-%E8%AE%BF%E9%97%AE)

这里需要注意，因为不再需要通过端口访问，所以只配置10.13.13.201，不需要:5000。

2. 下载habor离线包
[habor离线包github地址](https://github.com/goharbor/harbor/releases)
我这里下载的是2.5.0版本。

3. 解压安装

```shell
tar xf harbor-offline-installer-v2.5.0.tgz
cd harbor
docker load -i harbor.v2.5.0.tar.gz
cp harbor.yml.tmpl harbor.yml
vim  harbor.yml
#修改第5行主机名为当前主机的主机名
#注释15行，17行，18行 https相关的配置
#34行可以配置超管密码
./prepare #执行准备工作
./install.sh #安装
```

4. 项目及用户配置
安装完成后，通过访问10.13.13.201来访问服务，配置一个用户和项目，用来客户端使用。

## 客户端配置

### 登录
```shell
docker login 10.13.13.201
#根据提示输入之前页面中配置的账号密码
```

### 推送镜像
```shell
docker tag registry 10.13.13.201/registry_test/registry:v1 #通过tag命令添加自定义标签
docker push 10.13.13.201/registry_test/registry:v1 #推送镜像

```

### 下载镜像
```shell
docker pull 10.13.13.201/registry_test/registry:v1
```