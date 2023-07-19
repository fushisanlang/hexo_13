---
title: kubernetes学习笔记3-安装metric监控
tags:
  - cka
  - k8s
  - kubernetes
categories:
  - note
abbrlink: a0e26123
date: 2022-10-31 00:00:00
---

*个人CKA学习笔记，大部分内容源于《CKA/CKAD应试指南-从Docker到Kubernetes完全攻略》一书。*
# kubernetes学习笔记3-安装metric监控


1. 准备所需镜像
`在所有节点操作`
```shell
docker pull k8s.gcr.io/metrics-server-amd64:v0.3.6
```
2. 下载metrics-server
`在master节点操作`
```shell
curl -Ls https://api.github.com/repos/kubernetes-sigs/metrics-server/tarball/v0.3.6 -o m.tar.gz
```
3. 解压metrics-server并配置
`在master节点操作`

```shell
tar xf m.tar.gz
cd kubernetes-sigs-metrics-server-d1f4f6f/deploy/1.8+
vim metrics-server-deployment.yaml
```
```yaml
        imagePullPolicy: IfNotPresent #修改
        command:  #添加
        - /metrics-server #添加
        - --metric-resolution=30s #添加
        - --kubelet-insecure-tls  #添加
        - --kubelet-preferred-address-types=InternalIP     #添加
```
4. 运行目录下的文件
`在master节点操作`

```shell
kubectl apply -f .
```
5. 查看metrics-server的pod运行状态
`在master节点操作`

```shell
kubectl get pods -n kube-system | grep metrics
```
6. 查看负载
`在master节点操作`

经过几分钟准备后，可以通过kubectl命令查看负载
```shell
kubectl top nodes --use-protocol-buffers 
#查看节点负载，--use-protocol-buffers 可以不写
kubectl top pods kubectl top pods -n kube-system
#查看kube-system namespace下的pods负载
```

7. 注意
如果上一步运行时报错，得不到数据，可能是calico网络安装时出现问题
```shell
kubectl get pods -n kube-system -o wide | grep metrics
#通过这个命令可以查看metrics的网络信息，也可以查看其他节点，如果有多个节点没有ip地址，就可能是calico网络安装有问题

kubectl delete -f .
kubectl delete -f calico.yaml
#通过这两个命令可以删除calico，之后再重新确认配置，就可以解决问题，如果问题依旧未解决，就需要确认其他原因。

```