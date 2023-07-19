---
title: centos7 安装docker-ce
date: 2018-10-2
updated: 2018-10-3
tags:
  - docker
categories:
  - note
abbrlink: 866edd7c
---

```shell
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge
yum-config-manager --enable docker-ce-test
yum-config-manager --disable docker-ce-edge
yum install docker-ce
yum list docker-ce --showduplicates | sort -r
yum install docker-ce-18.06.1.ce
systemctl start docker
docker run hello-world
```

