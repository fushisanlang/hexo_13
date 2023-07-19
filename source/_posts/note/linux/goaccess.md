---
title: goaccess
date: 2016-5-5
updated: 2016-5-6
tags:
  - goaccess
categories:
  - note
abbrlink: 7559c030
---


```shell
yum -y install glib2 glib2-devel ncurses ncurses-devel GeoIP eoIP-devel goaccess

goaccess -d -f /usr/local/nginx/logs/2018/06/qd1b_access_20180614.log -a -p ~/.goaccessrc >/tmp/qd1b_access_20180614.html



goaccess -d -f qd_access_20171025.log -a -p ~/.goaccessrc >/tmp/qdaccess_20171026.html
```


GitHub 地址：https://github.com/allinurl/goaccess

官网地址：http://goaccess.io/

GoAccess日志规范：http://goaccess.io/man#custom-log 
