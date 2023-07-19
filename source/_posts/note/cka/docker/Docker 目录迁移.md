---
title: Docker 目录迁移
tags:
  - docker
categories:
  - note
abbrlink: 38ca807f
date: 2023-01-11 00:00:00
---

# Docker 目录迁移

## 背景
因公司docker默认会将容器和镜像放在/var/lib/docker目录下，/var基本属性linux的主分区（类似windows的c盘存放了操作系统文件的分区）所以没过多久就占满了。需要转移docker到其他分区。

## 准备
1. 确认迁移的目标目录空间是否充足
```shell
# 查看分区使用情况
df -lhT

# 查看docker目录当前大小
cd /var/lib/docker
du -h --max-depth=1 ./


# 建议新的存放目录使用lvm，这样方便后续扩容.
# 这里使用 /data/docker 作为实际存储路径
```
2. 备份 fstab文件

```shell
sudo cp /etc/fstab /etc/fstab.$(date +%Y-%m-%d)
```

## 迁移
1. 停止docker服务
```shell
service docker stop
```

2. 用rsync同步/var/lib/docker到新位置
```shell
rsync -aqXS --progress /var/lib/docker/.  /data/docker
```

3. 将原有路径备份，并新建挂载点
```shell
mv /var/lib/docker/ /data/docker_bak
mkdir /var/lib/docker/
```

4. 通过挂载mount的bind命令将新位置挂载到老位置
```shell
mount --bind /data/docker /var/lib/docker
mount -a
ls /var/lib/docker/
```
5. 创建开机自动挂载
```shell
vim /etc/fstab

# 最后一行添加
/mnt/docker /var/lib/docker                     none    bind            0 0
```
6. 重启服务器确认