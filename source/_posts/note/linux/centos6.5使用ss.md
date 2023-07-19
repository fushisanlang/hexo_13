---
title: centos 6.5使用ss
date: 2019-9-25
updated: 2019-9-26
tags:
  - ss
categories:
  - note
abbrlink: 5752adde
---

```shell
yum install  privoxy
# privoxy默认监听8118端口，可以在 /etc/privoxy/config里面自行配置
pip3 install shadowsocks
vim /etc/shadowsocks.json  #配置代理信息，配置完成后删除注释
	{
	"server":"SERVER-IP", # 你的服务器ip
	"server_port":PORT, # 服务器端口
	"local_address": "127.0.0.1",
	"local_port":1080,
	"password":"PASSWORD", # 密码
	"timeout":300,
	"method":"aes-128-cfb", # 加密方式
	"fast_open": false,
	"workers": 1
}

vim ~/.bashrc #配置环境变量，方便使用
	alias ssinit='nohup sslocal -c /etc/shadowsocks.json &>> /var/log/sslocal.log &'
	alias sson='export http_proxy=http://127.0.0.1:8118 && export https_proxy=http://127.0.0.1:8118 && service privoxy start'
	alias ssoff='unset http_proxy && unset https_proxy && service privoxy stop && pkill sslocal'
```

```shell
wget --no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
```

