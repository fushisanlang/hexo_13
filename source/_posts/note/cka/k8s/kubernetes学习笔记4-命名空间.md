---
title: kubernetes学习笔记4-命名空间
tags:
  - cka
  - k8s
  - kubernetes
categories:
  - note
abbrlink: '48431338'
date: 2022-10-31 00:00:00
---

*个人CKA学习笔记，大部分内容源于《CKA/CKAD应试指南-从Docker到Kubernetes完全攻略》一书。*
# kubernetes学习笔记4-命名空间

在进入一个命名空间之后，所看见的资源是分布在不同的worker上的。一般时候，我们不需要知道是在具体哪个worker上的。只需要在某命名空间对资源进行操作即可。

`ftp.rhce.cc/cka-tool/kubens` 是一个比较好的工具，用来切换命名空间


* 查看当前有多少命名空间
```shell
kebectl get ns
```
* 查看当前所在命名空间
```shell
wget ftp://ftp.rhce.cc/cka-tool/kubens -P /bin/
chmod +x /bin/kubens
kubens
```

* 创建新的命名空间
```shell
kubectl create ns ns1
kebectl get ns
```

* 切换命名空间
```shell
kubens ns1
kubens
kubens default
kubens
```

* 删除命名空间
```shell
kubectl delete ns ns1
```
* 其余命令
```shell
kubectl config set-context <集群名> --namespace=<命名空间>
如果集群没有发生切换，可以使用如下命令
kubectl config set-context --current --namespace=<命名空间>
```

