---
title: 通过rke etcd 备份恢复rancher集群配置
tags:
  - rke
  - k8s
  - kubernetes
  - rancher
categories:
  - note
abbrlink: 3c4ba8f0
date: 2022-11-02 00:00:00
---


# 通过rke etcd 备份恢复rancher集群配置

## 1. 环境说明
ip|hostname|info
-|-|-
192.168.122.101|rke-a1.fushisanlang.cn|旧集群节点1
192.168.122.102|rke-a2.fushisanlang.cn|旧集群节点1
192.168.122.103|rke-a3.fushisanlang.cn|旧集群节点1
192.168.122.201|rke-b1.fushisanlang.cn|新集群节点1
192.168.122.202|rke-b2.fushisanlang.cn|新集群节点1
192.168.122.203|rke-b3.fushisanlang.cn|新集群节点1
192.168.122.1|server.fushisanlang.cn|备份服务器

旧集群通过 `ncl` 用户，使用 `rke` 工具进行集群创建。
rancher版本为 `v2.6.6`
rke版本为 `v1.3.13-rc4`


## 2. 收集旧集群配置备份
### 2.1 集群配置文件
```bash
[root@rke-a1 ~]# scp /home/ncl/rancher/rancher-cluster.yml root@server.fushisanlang.cn:/bak/rancher
```
### 2.2 etcd文件
```shell
#每个etcd节点，在确认集群状态正常后都会在自己服务器路径下生成备份文件，备份时选择一个最新的即可 具体配置在rancher-cluster.yml 
[root@rke-a1 ~]# scp /opt/rke/etcd-snapshots/2022-11-02T05:50:46Z_etcd.zip root@server.fushisanlang.cn:/bak/rancher
```

## 3. 准备新集群
### 3.1 搭建新集群
[配置高可用的 RKE Kubernetes 集群](https://docs.ranchermanager.rancher.io/zh/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke1-for-rancher)

### 3.2 清理集群配置，准备还原


[环境清理脚本](https://docs.rancher.cn/docs/rancher2/cluster-admin/cleaning-cluster-nodes/_index)
```shell

docker rm -f $(sudo docker ps -aq);
docker volume rm $(sudo docker volume ls -q);

rm -rf /etc/cni \
       /etc/kubernetes \
       /opt/cni \
       /opt/rke \
       /run/secrets/kubernetes.io \
       /run/calico \
       /run/flannel \
       /var/lib/calico \
       /var/lib/etcd \
       /var/lib/cni \
       /var/lib/kubelet \
       /var/lib/rancher/rke/log \
       /var/log/containers \
       /var/log/pods \
       /var/run/calico

for mount in $(mount | grep tmpfs | grep '/var/lib/kubelet' | awk '{ print $3 }') /var/lib/kubelet /var/lib/rancher; do umount $mount; done

rm -f /var/lib/containerd/io.containerd.metadata.v1.bolt/meta.db

# 清理Iptables表
## 注意：如果节点Iptables有特殊配置，以下命令请谨慎操作
sudo iptables --flush
sudo iptables --flush --table nat
sudo iptables --flush --table filter
sudo iptables --table nat --delete-chain
sudo iptables --table filter --delete-chain
 
sudo systemctl restart containerd docker
```

## 4. 准备还原

### 4.1 放置配置文件
```shell 
#准备etcd备份
[root@rke-b1 ~]# mkdir -p /opt/rke/etcd-snapshots
[root@rke-b1 ~]# scp root@server.fushisanlang.cn:/bak/rancher/2022-11-02T05:50:46Z_etcd.zip /opt/rke/etcd-snapshots
[root@rke-b1 ~]# cd /opt/rke/etcd-snapshots
[root@rke-b1 etcd-snapshots]# unzip 2022-11-02T05:50:46Z_etcd.zip

#准备rancher集群配置备份
[root@rke-b1 etcd-snapshots]# su - ncl
[ncl@rke3 ~]$ mkdir rancher
[ncl@rke3 ~]$ cd rancher
[ncl@rke3 rancher]$ scp root@server.fushisanlang.cn:/bak/rancher/rancher-cluster.yml .

#将配置文件中的ip修改为新集群的node ip
[ncl@rke3 rancher]$ sed 's/192.168.122.101/192.168.122.201/g' -i rancher-cluster.yml
[ncl@rke3 rancher]$ sed 's/192.168.122.102/192.168.122.202/g' -i rancher-cluster.yml
[ncl@rke3 rancher]$ sed 's/192.168.122.103/192.168.122.203/g' -i rancher-cluster.yml

```
### 4.2 恢复集群
```shell
[ncl@rke3 rancher]$ rke etcd snapshot-restore --name 2022-11-02T05:50:46Z_etcd --config ./rancher-cluster.yml
#命令执行成功之后，会有类似如下的提示信息，提示etcd配置重装成功
#INFO[0111] Finished restoring snapshot [2022-11-02T05:50:46Z_etcd] on all etcd hosts 
```

