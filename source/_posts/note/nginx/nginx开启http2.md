---
title: nginx开启http2
date: 2017-4-2
updated: 2017-4-3
tags:
  - nginx
  - http2
categories:
  - note
abbrlink: 49df52af
---
在编译时添加http_v2模块即可
```shell
./configure --prefix=/usr/local/nginx --user=www --group=www \
--with-http_stub_status_module --with-http_ssl_module \
--without-mail_pop3_module --without-mail_smtp_module \
--without-mail_imap_module --add-module=/soft/nginx_new/naxsi-master/naxsi_src \
--add-module=/soft/nginx_new/nginx-limit-upstream-master \
--add-module=/soft/nginx_new/nginx-upstream-jvm-route-master \
--add-module=/soft/nginx_new/ngx_http_proxy_connect_module-master \
--with-http_v2_module 
```

在server配置时，在listen 中加入http2即可：

```conf
server {
    listen 443 http2;
    server_name www.baidu.com
    .......
}
```