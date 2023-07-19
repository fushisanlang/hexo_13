---
title: Nginx并发下限流基础知识以及一些思路
tags:
  - nginx
categories:
  - note
abbrlink: a7c83deb
date: 2023-01-11 00:00:00
---

### Nginx并发下限流基础知识以及一些思路


#### 文档
[tengine翻译文档](http://tengine.taobao.org/nginx_docs/cn/docs/)

#### 一些用到的变量
```shell
$binary_remote_addr 二进制格式的客户端地址。例如：\x0A\xE0B\x0E
$remote_addr        客户端IP地址
$server_name        nginx内置变量，表示当前服务器
```

#### nginx限制请求数量

* 限速(比如下载文件的时候)
```
    location ~ \.php$ {
        #限制速度为10k
        limit_rate 10k;
        root           /data/www;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
```

* ngx_http_limit_req_module模块
```
    #对单个ip地址的请求进行访问限制

    http {
        #http下配置如下，
        #$binary_remote_addr为请求ip转为二进制的变量，可以将每条状态记录的大小减少到64个字节，
        #这样1M的内存可以保存大约1万6千个64字节的记录
        #zone=one，就是给这个设置配置个名称
        #10m就是排队ip缓存空间大小为10m
        #rate=1r/s，就是1s内只处理一个请求，1r/m就是一分钟接受一个请求，其他请求排队等待，
                    超过排队限额的请求直接返回503
        limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

    ...

    server {

        ...

        location /search/ {
                #zone代表取http下配置的同名(one)的配置。
                #burst=5代表排队的请求超过5的时候，其余的请求直接503
                #nodelay 不希望超过的请求被延迟，可以用nodelay参数，可选
            limit_req zone=one burst=5 nodelay;
        }

```

* ngx_http_access_module模块
```
    #允许限制某些IP地址的客户端访问，默认是允许所有ip访问，若部分允许需定义 deny all

    #allow允许某些地址访问
    #deny不允许某些地址访问

    location / {
        deny  192.168.1.1;
        allow 192.168.1.0/24;
        allow 10.1.1.0/16;
        allow 2001:0db8::/32;
        deny  all;
    }


    location ~.*\.(sql|log|txt|jar|war|sh|py|php) {     
        deny all; 
    }

```

* ngx_http_limit_conn_module模块
```
    限制请求连接数


    http {
        #zone 名称
        #10m,10m存储空间
        limit_conn_zone $binary_remote_addr zone=addr:10m;
        #根据服务器配置$server_name
        limit_conn_zone $server_name zone=curServer:10m;
    ...

    server {

        ...

        location /download/ {
            #同一个来源ip同一时间只能连接一个请求
            limit_conn addr 1;
            #整个服务器同一时间并发连接最大数
            limit_conn curServer 100;
        }

```
* ip黑白名单
```
    ngx_http_geo_module  创建变量，并根据客户端IP地址对变量赋值
    ngx_http_map_module  可以创建一些和另外变量相关联的变量

        http{
            #ngx_http_geo_module并根据客户端IP地址对变量赋值
            #按照如下配置 
            #$geo为创建的变量，$geo的值当ip为8.8.8.3的时候为1，同理，8.8.8.4的时候为1，其他为0
            geo $geo {
                default        0;
                8.8.8.3 1;
                8.8.8.4 1;
                #注意，这里可以写在单独的文件里，并且可以取IP段比如8.8.8.0/24；
            }

            #ngx_http_map_module  可以创建一些和另外变量相关联的变量
            #$geo为上面创建的变量
            #这里的意思是当$geo的值为0的时候,$limit_ip为空，$geo为1的时候，$limit_ip的值为客户端ip
            map $geo $limit_ip {
                0 "";
                1 $remote_addr;
            }


            server{

            }
            ……
        }
```
如上，结合两个模块，就可以得出 `$limit_ip` ，`$limit_ip` 为空则限制失败，也就是不限制。
`$limit_ip` 非空则为当前客户端ip。

然后将 `limit_ip` 替换 `$binary_remote_addr` ，即只针对 `limit_ip` 进行限流，其他不限
例如：
```
  --limit_req_zone $limit_ip zone=one:10m rate=1r/s;
  --limit_conn_zone $limit_ip zone=addr:10m;
```

#### nginx限流思路
`nginx`限流主要从两个方面来:
* 限制用户访问频率
  * 如果网站正常,做正常的频率限制,利用上面的`req`模块根据实际情况配置
  * 如果网站做秒杀等突发流量活动，可限制突发访问频率,也是利用上面`req`模块处理,唯一不同的就是配置`burst`和`nodelay`,将过多的请求直接排除掉


* 限制并发连接数
  * 利用上面的`conn`模块，根据实际情况配置。可配置单个`ip`并发连接数(`$binary_remote_addr`)，总共的并发连接数`$server_name`(当前服务器名称，`nginx`内置变量)