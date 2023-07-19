---
title: nginx 基于ngx_http_proxy_connect_module模块实现http/https正向代理
date: 2017-1-1
updated: 2017-1-2
tags:
  - nginx
  - 正向代理
  - note
categories:
  - note
abbrlink: f5004f90
---

# nginx 基于ngx_http_proxy_connect_module模块实现http/https正向代理



## 背景介绍

在网上查询相关内容发现，nginx默认的正向代理功能是不支持https的正向代理的。配置了reslover之后访问https的网站会显示证书错误。

网上给出的一种解决方案是 **用 Nginx 实现 Socket 转发，然后使用 Squid 实现 http/https 代理。**

后来找到了一个nginx的第三方模块**ngx_http_proxy_connect_module**，可以只通过nginx实现正向代理功能。



## 环境

Centos 6.7 x64

nginx 1.12.1



## 配置安装

#### 下载模块

```shell
wget https://codeload.github.com/chobits/ngx_http_proxy_connect_module/zip/master
unzip master
mv ngx_http_proxy_connect_module-master /soft
```

#### 编译安装nginx

```shell
cd /soft/nginx-1.12.1
patch -p1 < /soft/ngx_http_proxy_connect_module-master/patch/proxy_connect_1014.patch
./configure --add-module=/soft/ngx_http_proxy_connect_module-master --with-http_ssl_module --with-stream

#--add-module=/soft/ngx_http_proxy_connect_module-master 这个就是 ngx_http_proxy_connect_module 模块的位置
#--with-http_ssl_module 这个是 https 要用到的模块
#--with-stream 这个是 Socket 转发需要的模块

#如果还需其他模块和编译参数，请自行调着编译命令
make && make install
```

#### 配置代理

```nginx
# Socket转发 ---开始----
stream {
    upstream trans {
        # 要转发的目标服务器的 IP 与端口
        server 110.76.15.107:443;
    }

    server {
        # 本机监听端口
        listen 8008;
        proxy_pass trans;
    }
}
# Socket转发 ---结束--

http {
    # http/https代理 ---开始----
    server {
        listen                         8009;
        # dns resolver used by forward proxying
        resolver                       223.5.5.5;
        # forward proxy for CONNECT request
        proxy_connect;
        proxy_connect_allow            443 563;
        proxy_connect_connect_timeout  10s;
        proxy_connect_read_timeout     10s;
        proxy_connect_send_timeout     10s;

        # forward proxy for non-CONNECT request
        location / {
            proxy_pass http://$host;
            proxy_set_header Host $host;
        }
    }
    # http/https代理 ---结束----
}
```



## linux配置代理服务

```shell
#添加代理
export http_proxy=http://1.1.1.1:1111  #配置成nginx的ip及配置好的http代理端口即可
#取消代理
unset http_proxy

#如果想长期使用代理，可以将上述添加名令放置在环境变量的配置文件中，使其一直生效。
```

