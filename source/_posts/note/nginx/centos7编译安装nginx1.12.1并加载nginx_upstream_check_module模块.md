---
title: centos 7 编译安装nginx1.12.1并加载nginx_upstream_check_module模块
date: 2018-12-23
updated: 2018-12-24
tags:
  - nginx
  - nginx_upstream_check_module
categories:
  - note
abbrlink: 89b77a2b
---
# centos 7 编译安装nginx1.12.1并加载nginx_upstream_check_module模块


## 1、模块说明

- 模块名称：nginx_upstream_check_module
	- [x] [https://github.com/yaoweibin/nginx_upstream_check_module]

> nginx自带的针对后端节点健康检查的功能比较简单，通过默认自带的ngx_http_proxy_module 模块和ngx_http_upstream_module模块中的相关指令来完成当后端节点出现故障时，自动切换到健康节点来提供访问。
>
> 这种情况Nginx无法主动识别后端节点状态，后端即使有不健康节点， 负载均衡器依然会先把该请求转发给该不健康节点，然后再转发给别的节点，这样就会浪费一次转发，而且自带模块无法做到预警。所以此时使用第三方模块 nginx_upstream_check_module模块。
>
> 该模块是一个第三方模块，用于nginx后端负载的健康检查。支持tcp，http等多种检查模式。



## 2、安装环境介绍

|平台|NGINX版本| 安装模块|
|:-:|:-:|:-:|
| CentOS 7.8 64Bit | NGINX-1.12.1 | nginx_upstream_check_module |



## 3、Nginx安装步骤

### 3.1、安装系统工具
```shell
```

### 3.2、安装编译开发组件
```shell
[root@localhost ~]# yum groupinstall "Development Tools" -y
```

### 3.3、安装EPEL源
```shell
[root@localhost ~]# yum install epel-release
```

### 3.4、安装NGINX各项依赖组件
```shell
[root@localhost ~]# yum install pcre-devel zlib-devel libjpeg-devel libpng-devel freetype-devel openssl-devel curl curl-devel libxml2 libxml2-devel libjpeg libjpeg-devel libpng libpng-devel libmcrypt libmcrypt-devel openldap openldap-devel openssh-clients -y
```


### 3.5、解压nginx及各项模块
```shell
[root@localhost ~]# cd /soft 
#上传源码文件
[root@localhost soft]# unzip nginx_upstream_check_module-master.zip
[root@localhost soft]# tar xzvf nginx-1.12.1.tar.gz
```

### 3.6、安装nginx及各项模块
```shell
[root@localhost soft]# cd nginx-1.12.1
[root@localhost nginx-1.12.1]# patch -p1 < ../nginx_upstream_check_module-master/check_1.12.1+.patch
[root@localhost nginx-1.12.1]# useradd -s /sbin/nologin -M www

[root@localhost nginx-1.12.1]# ./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --without-mail_pop3_module --without-mail_smtp_module --without-mail_imap_module --add-module=../nginx_upstream_check_module-master #如有其他模块需要安装，可以一并安装
[root@localhost nginx-1.12.1]# chown www.www /usr/local/nginx -R
```

### 3.7、测试与验证
```shell
[root@localhost sbin]# pwd
/usr/local/nginx/sbin
[root@localhost sbin]# ./nginx -V
nginx version: 
built by gcc 4.4.7 20120313 (Red Hat 4.4.7-18) (GCC) 
built with OpenSSL 1.0.1e-fips 11 Feb 2013
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --without-mail_pop3_module --without-mail_smtp_module --without-mail_imap_module --add-module=../naxsi-master/naxsi_src --add-module=../nginx-limit-upstream-master --add-module=../nginx-upstream-jvm-route-master --add-module=../nginx_upstream_check_module-master  
#这里的nginx其实添加了其他的模块。只要确定nginx_upstream_check_module-master模块存在即可
```

### 3.8、配置启动文件
```shell
[root@localhost sbin]# vi /usr/lib/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP Server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target

[root@localhost sbin]# systemctl daemon-reload
[root@localhost sbin]# systemctl enable nginx.service
```

### 3.8、配置nginx
```shell
#该模块的配置示例如下，具体配置说明详见附1
http{

    upstream cluster1 {
        server 39.107.234.33:31313;
        server 39.107.234.33:30009;
        check interval=3000 rise=2 fall=2 timeout=1000 type=http;
        check_keepalive_requests 100;
        check_http_send "HEAD /api/all HTTP/1.1\r\nConnection: keep-alive\r\n\r\n";
        check_http_expect_alive http_2xx;
    }
    server {
        listen 80;
        server_name 192.168.92.130;
        location /1 {
            proxy_pass http://cluster1;
        }
        location /status {
            check_status;
            access_log   off;
            allow 127.0.0.1；
            deny all;
        }
    }
}
```
在nginx配置文件的 `http` 块配置上述参数，即可通过调用 `nginx_upstream_check_module` 的方式对后端集群进行负载。
其中 `/status` 是健康检查的页面，需要注意访问权限。

## 附1：模块配置项说明

### check字段

```shell
Syntax: check interval=milliseconds [fall=count] [rise=count] [timeout=milliseconds] [default_down=true|false] [type=tcp|http|ssl_hello|mysql|ajp] [port=check_port]

Default: 如果没有配置参数，默认值是：interval=30000 fall=5 rise=2 timeout=1000 default_down=true type=tcp
```

- `interval`：向后端发送的健康检查包的间隔。

- `fall(fall_count)`: 如果连续失败次数达到fall_count，服务器就被认为是down。

- `rise(rise_count)`: 如果连续成功次数达到rise_count，服务器就被认为是up。

- `timeout`: 后端健康请求的超时时间。

- `default_down`: 设定初始时服务器的状态，如果是true，就说明默认是down的，如果是false，就是up的。

  默认值是true，也就是一开始服务器认为是不可用，要等健康检查包达到一定成功次数以后才会被认为是健康的。

- `type`：健康检查包的类型，现在支持以下多种类型   

  - `tcp`：简单的tcp连接，如果连接成功，就说明后端正常。

  - `ssl_hello`：发送一个初始的SSL hello包并接受服务器的SSL hello包。

  - `http`：发送HTTP请求，通过后端的回复包的状态来判断后端是否存活。

  - `mysql`: 向mysql服务器连接，通过接收服务器的greeting包来判断后端是否存活。

  - `ajp`：向后端发送AJP协议的Cping包，通过接收Cpong包来判断后端是否存活。

  - `port`: 指定后端服务器的检查端口。

    可以指定不同于真实服务的后端服务器的端口，比如后端提供的是443端口的应用，你可以去检查80端口的状态来判断后端健康状况。

    默认是0，表示跟后端server提供真实服务的端口一样。



### check_http_expect_alive 字段

`check_http_expect_alive` 指定主动健康检查时HTTP回复的成功状态：

```shell
Syntax: check_http_expect_alive [ http_2xx | http_3xx | http_4xx | http_5xx ]

Default: http_2xx | http_3xx
```



### check_http_send 字段

`check_http_send` 配置http健康检查包发送的请求内容

为了减少传输数据量，推荐采用”HEAD”方法。当采用长连接进行健康检查时，需在该指令中添加keep-alive请求头，如：”HEAD / HTTP/1.1\r\nConnection: keep-alive\r\n\r\n”。同时，在采用”GET”方法的情况下，请求uri的size不宜过大，确保可以在1个interval内传输完成，否则会被健康检查模块视为后端服务器或网络异常。

```shell
Syntax: check_http_send http_packet

Default: "GET / HTTP/1.0\r\n\r\n"
```
