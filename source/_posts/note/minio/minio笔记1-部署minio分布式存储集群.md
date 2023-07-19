---
title: minio笔记1-部署minio分布式存储集群
tags:
  - minio
  - 存储
categories:
  - note
abbrlink: '98398717'
date: 2022-11-28 00:00:00
---

# minio笔记1-部署minio分布式存储集群

## 环境准备
1. 服务器环境

主机ip|主机名|操作系统|cpu核心数|内存/G|系统盘/G|数据盘/G
-|-|-|-|-|-|-
10.13.13.117|minio1.vm.fu|centos7 X86_64|2|4|vda:5|vdb:10
10.13.13.118|minio2.vm.fu|centos7 X86_64|2|4|vda:5|vdb:10
10.13.13.119|minio3.vm.fu|centos7 X86_64|2|4|vda:5|vdb:10
10.13.13.120|minio4.vm.fu|centos7 X86_64|2|4|vda:5|vdb:10

2. 软件版本
```shell
minio -v
minio version RELEASE.2022-11-17T23-20-09Z (commit-id=a22b4adf4c5cc3e4db13fe92da683ef1ce45cd5a)
Runtime: go1.19.3 linux/amd64
License: GNU AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>
Copyright: 2015-2022 MinIO, Inc.
```
## 部署准备
**如未特殊说明，以下所有步骤需要在所有服务器执行**

1. 关闭防火墙，关闭selinux

```shell
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed 's/SELINUX=enforcingSELINUX=disabled//g' /etc/sysconfig/selinux
```
2. 安装epel源
```shell
yum install -y epel-release
```
3. 配置主机名及hosts文件
```shell
hostnamectl set-hostname minio{id}.vm.fu
#如果用dns服务器，将这几台服务器hostname信息及解析配置进去，如果没有就通过hosts文件的方式配置，达到互相能够解析的效果

```
4. 设置主机间免密登陆，方便交换文件
```shell
# 在一台主机上操作即可
ssh-keygen #生成公私钥，如果以前生成过，则不要重新重新生成
ssh-copy-id 127.0.0.1 . #对自己进行免密设置，按照提示输入密码
scp -pr ~/.ssh 10.13.13.{id}:~ . #将公私钥及认证文件同步，按照提示输入密码
```
5. 准备硬盘
```shell
# 注意盘符，我这里是vdb
mkfs.xfs /dev/vdb  #minio官方推荐xfs，其他文件系统性能不好，也可能出现问题

blkid | grep /dev/vdb | awk '{print $2}' | sed 's/$/ \/data\/minio1     xfs     defaults\,noatime  0       2/g'  >> /etc/fstab  #将vdb挂载到/data/minio1路径下 noatime参数可以提高速度

mkdir -p /data/minio1 #准备挂载点
mount -a #挂载
```

6. 准备用户
```shell
# minio默认不以root用户运行，需要提前准备用户
groupadd -r minio-user
useradd -M -r -g minio-user minio-user
chown minio-user:minio-user /data/minio1
```

7. 安装软件
```shell
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio-20221117232009.0.0.x86_64.rpm -O minio.rpm
yum install minio.rpm -y
```
8. 准备配置文件
```shell
echo MINIO_VOLUMES="http://minio{1...4}.vm.fu:9000/data/minio1" >> /etc/default/minio #注意hostname和路径。这里使用四台主机，每个主机各一块磁盘组建集群。需要注意，括号中必须是正整数，且前一个要比后一个小，差值最小为4
echo MINIO_OPTS="--console-address :9001" >> /etc/default/minio
echo MINIO_ROOT_USER=admin1234qwer >> /etc/default/minio #管理用户
echo MINIO_ROOT_PASSWORD=qwer1234qwer1234 >> /etc/default/minio #管理用户密码
echo MINIO_SERVER_URL="http://10.13.13.120:9000" >> /etc/default/minio #访问路径，官方推荐nginx或者haproxy作为lb进行负载，如果使用lb，这里配置lb的访问地址。如果未使用lb，这里填写随便一个节点的地址即可。
``` 

9. 启动
```shell
systemctl restart minio.service
systemctl status minio.service #查看状态
```

10. web访问
```shell
# 如果服务重启后正常，通过浏览器访问集群中任意服务器的9001端口既可以访问到服务
```