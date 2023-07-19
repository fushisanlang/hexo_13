---
title: kubernetes学习笔记2-节点删除
tags:
  - cka
  - k8s
  - kubernetes
categories:
  - note
abbrlink: 7bbc7165
date: 2022-10-31 00:00:00
---

*个人CKA学习笔记，大部分内容源于《CKA/CKAD应试指南-从Docker到Kubernetes完全攻略》一书。*
# kubernetes学习笔记2-节点删除


1. 将k8s-s1.fushisanlang.cn设置为维护模式
`在master节点操作`
```shell
kubectl drain k8s-s1.fushisanlang.cn --delete-local-data --force --ignore-daemonsets
```
2. 删除此节点
`在master节点操作`
```shell
kubectl delete node k8s-s1.fushisanlang.cn
kubectl get nodes
#k8s-s1.fushisanlang.cn已经不在列表中
```

3. 清空k8s-s1.fushisanlang.cn节点配置
`在k8s-s1.fushisanlang.cn上执行`
```shell
kubeadm reset
```
4. 重新加入集群
`在k8s-s1.fushisanlang.cn上执行`
```shell
kubeadm join 192.168.122.100:6443 --token i5sqtk.ekvz51wnlt5ujmyo --discovery-token-ca-cert-hash sha256:cd8db6e508b5d15a3e87217c3c5b8b085735c023b8f6446e1c3315831000763b
#需要提前确认token是否可用，不可用需要在master节点上重新生成后，再加入
```