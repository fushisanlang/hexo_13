---
title: centos 7 安装nginx1.12.1
date: 2018-8-6
updated: 2018-8-7
tags:
  - nginx
categories:
  - note
abbrlink: '51966423'
---

## 1、所需模块
- 模块名称：ngx_http_limit_conn_module
- 模块名称：ngx_http_limit_req_module
- 模块名称：ngx_http_geo_module
- 模块名称：ngx_http_map_module
- 模块名称：ngx_http_geoip_module
- 模块名称：naxsi
	- [x] [https://github.com/nbs-system/naxsi][https://github.com/nbs-system/naxsi]
- 模块名称：nginx-limit-upstream
	- [x] [https://github.com/cfsego/nginx-limit-upstream/][https://github.com/cfsego/nginx-limit-upstream/]
- 模块名称：nginx-upstream-jvm-route
	- [x] [https://github.com/nulab/nginx-upstream-jvm-route][https://github.com/nulab/nginx-upstream-jvm-route]
- 模块名称：ngx_http_proxy_connect_module
	- [x] [https://codeload.github.com/chobits/ngx_http_proxy_connect_module/zip/master]
---


## 2、安装环境介绍
| 平台             | NGINX版本    | 安装模块                                            |
| :----------------: |: ------------: |: ---------------------------------------------------: |
| CentOS 7.6 64Bit | NGINX-1.12.1 | naxsi\nginx-limit-upstream\nginx-upstream-jvm-route\ngx_http_proxy_connect |

---

## 3、Nginx安装步骤
### 3.1、安装系统工具
```shell
[root@localhost ~]# yum install vim telnet wget nethogs htop glances dstat traceroute lrzsz goaccess ntpdate dos2unix openssl-devel tcpdump lrzsz fio -y
```

### 3.2、安装编译开发组件
```shell
[root@localhost ~]# yum groupinstall "Development Tools" -y
```

### 3.3、安装EPEL源
```shell
[root@localhost ~]# rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/Packages/e/epel-release-6-8.noarch.rpm
```

### 3.4、安装NGINX各项依赖组件
```shell
[root@localhost ~]# yum install pcre-devel zlib-devel libjpeg-devel libpng-devel freetype-devel openssl-devel curl curl-devel libxml2 libxml2-devel libjpeg libjpeg-devel libpng libpng-devel libmcrypt libmcrypt-devel openldap openldap-devel openssh-client -y
```


### 3.5、解压nginx及各项模块
```shell
[root@localhost soft]# unzip nginx-limit-upstream-master.zip
###nginx负载限制模块
[root@localhost soft]# unzip naxsi-master.zip
###nginx软防火墙
[root@localhost soft]# tar xzvf nginx-1.12.1.tar.gz
###nginx主程序
[root@localhost soft]# unzip nginx-upstream-jvm-route-master.zip
###cookie粘贴模块
[root@localhost soft]# unzip ngx_http_proxy_connect_module-master.zip
###正向代理模块
```

### 3.6、安装nginx及各项模块
```shell
[root@localhost soft]# cd nginx-1.12.1
[root@localhost nginx-1.12.1]#  patch -p0 < /soft/nginx-limit-upstream-master/nginx-1.10.1.patch

[root@localhost nginx-1.12.1]# patch -p0 < /soft/nginx-upstream-jvm-route-master/jvm_route.patch

[root@localhost nginx-1.12.1]# patch -p1 < /soft/ngx_http_proxy_connect_module-master/patch/proxy_connect_1014.patch

[root@localhost nginx-1.12.1]# useradd -s /sbin/nologin -M www

[root@localhost nginx-1.12.1]# ./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --without-mail_pop3_module --without-mail_smtp_module --without-mail_imap_module --add-module=/soft/nginx/ngx_http_proxy_connect_module-master --add-module=/soft/naxsi-master/naxsi_src --add-module=/soft/nginx-limit-upstream-master --add-module=/soft/nginx-upstream-jvm-route-master && make && make install

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
configure arguments: --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --without-mail_pop3_module --without-mail_smtp_module --without-mail_imap_module --with-http_ssl_module --add-module=/soft/naxsi-master/naxsi_src --add-module=/soft/nginx-limit-upstream-master --add-module=/soft/nginx-upstream-jvm-route-master
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