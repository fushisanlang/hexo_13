---
title: redhat7 yum源
date: 2017-1-8
updated: 2017-1-9
categories:
  - note
abbrlink: 4ce3bc0b
---
# redhat7 yum源



[root@localhost ~]# wget -O /etc/yum.repos.d/[CentOS](http://www.linuxidc.com/topicnews.aspx?tid=14)-Base.repo <http://mirrors.aliyun.com/repo/Centos-7.repo>

[root@localhost ~]# sed -i  's/$releasever/7/g' /etc/yum.repos.d/CentOS-Base.repo

[root@localhost ~]# yum clean all

[root@localhost ~]# yum list