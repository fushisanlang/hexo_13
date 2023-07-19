---
title: >-
  解决 no ssl_certificate” is defined in server listening on SSL port while SSL
  handshaking
tags:
  - nginx
categories:
  - note
abbrlink: 1eb46da8
date: 2021-12-23 00:00:00
updated: 2021-12-23 00:00:00
---

## 现象
在一次重启nginx之后，发现整个网站的https访问均受影响。
核查了域名证书之后发现证书正常。
后来在日志中发现nginx有报错”no ssl_certificate” is defined in server listening on SSL port while SSL handshaking“

## 处理过程

### 检查nginx配置文件
使用 `nginx -t` 重新检查了配置文件，发现没有错误

### 重新编译nginx
因为使用了lua模块，nginx日志中有关于lua的alert报错。当时因为与此有关，重新编译了一次nginx，结果无效

### 恢复配置
使用了当日0点的nginx备份，对nginx的配置目录，证书目录进行了还原，问题依旧。
（这里其实有个小问题。这里还原的时候是t+1，是在异常的后一天。但是当时没有注意日期，使用的是t+1 0时的备份，导致配置依旧是错的。）

### 使用网上的配置临时恢复
在网上搜了一下报错，在nginx的主域名配置里，加上了 `listen 443 default_server ssl;` 的配置，重启nginx后，网站恢复。
当时博客说的是，可能由于服务器的某些更新导致的。


### 最终解决
修复之后总觉得怪怪的，查了一下message日志，确定并没有安装过任何更新。所以又去google了一下。
看到有人说应该是某些443端口伤的服务没配置ssl证书。
于是在自己的vhost里边翻了一圈，找到了一个临时的配置。
这个配置是前一天帮一个同事验证nginx的语法放进来的，当时因为没有他网站的证书，所以把证书相关的配置的都注释了。当时通过 `nginx -t` 验证无误之后就去忙别的了。
再后来改了一个nginx配置之后，重启了nginx，导致了异常。
删除了临时的配置文件以及 `listen 443 default_server ssl;` 的配置，重启nginx之后，一切正常。

### 警示
1. 没事不要动配置。
2. 测试去测试机器，不要用生产服务。
3. 查问题注意方式方法。对照着日志看现象，不要没头没脑看见个问题就当成主要问题。
4. 操作时候看好，不要用明显有问题的配置去恢复。注意备份的日期。
5. 手稳，稳住。
6. 问题尽量不要拖，不然当天恢复t-1的配置，屁事没有。
7. 一天天啥也不是，收工。