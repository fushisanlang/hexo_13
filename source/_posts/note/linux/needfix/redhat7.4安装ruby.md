---
title: redhat7
date: 2019-7-22
updated: 2019-7-23
categories:
  - note
abbrlink: 9679361e
---
# redhat7.4安装ruby



* 环境介绍
```
[root@localhost Python-3.6.6]# cat /etc/redhat-release 
Red Hat Enterprise Linux Server release 7.4 (Maipo)
[root@localhost Python-3.6.6]# uname -a
Linux localhost.localdomain 3.10.0-693.el7.x86_64 #1 SMP Thu Jul 6 19:56:57 EDT 2017 x86_64 x86_64 x86_64 GNU/Linux
[root@localhost Python-3.6.6]# getenforce 
Disabled
[root@localhost Python-3.6.6]# systemctl status firewalld.service 
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)

     Docs: man:firewalld(1)
[root@localhost Python-3.6.6]# 
```


* 安装

```
yum install ruby
```

