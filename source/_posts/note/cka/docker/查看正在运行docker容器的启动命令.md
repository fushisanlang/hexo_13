---
title: 查看正在运行docker容器的启动命令
tags:
  - docker
categories:
  - note
abbrlink: fa2692a1
date: 2022-09-15 15:00:00
---
# 查看正在运行docker容器的启动命令

### 通过docker ps命令

```shell
docker ps -a --no-trunc | grep container_name   # 通过docker --no-trunc参数来详细展示容器运行命令
```

### 通过docker inspect命令
```shell

docker inspect <container_name>   # 可以是container_name或者container_id
 
# 默认的输出信息很多，可以通过-f, --format格式化输出：
docker inspect --format='{{.NetworkSettings.Networks.bridge.IPAddress}}' <container_name>      # format是go语言的template，还有其他的用法   
```

### 通过runlike三方包
```shell
# 安装runlike安装包
pip install runlike
 
# 运行命令
runlike -p <container_name>  # 后面可以是容器名和容器id，-p参数是显示自动换行
```