---
title: mysql输入密码无法登陆
date: 2017-12-17
updated: 2017-12-18
categories:
  - note
abbrlink: 2ee57458
---
### mysql输入密码无法登陆

密码正确，但是无法登陆。
跳过认证后可以登陆。
此时需要检查user表大小。
可能user表在初始化的时候未生成。
重新执行mysql_install_db --user=mysql --datadir=/data/mysql
重新初始化即可。