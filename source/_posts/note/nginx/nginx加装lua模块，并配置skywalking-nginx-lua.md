---
title: nginx加装lua模块，并配置skywalking-nginx-lua
date: 2020-2-14
updated: 2020-2-15
tags:
  - nginx
  - lua
  - skywalking
categories:
  - note
abbrlink: cd3cbe9
---
## 版本说明
软件|版本
-|-
os|CentOS Linux release 7.8.2003 (Core)
nginx|1.12.1
skywalking-nginx-lua|0.3.0
skywalking|8.3.0


## nginx加装lua模块

### 安装luajit
```shell
wget http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz
tar xf LuaJIT-2.1.0-beta3.tar.gz 
cd LuaJIT-2.1.0-beta3
make PREFIX=/usr/local/luajit
make install PREFIX=/usr/local/luajit
echo 'export LUAJIT_LIB=/usr/local/luajit/lib' >> /etc/profile
echo 'export LUAJIT_INC=/usr/local/luajit/include/luajit-2.1' >> /etc/profile
source /etc/profile
```

### 下载lua模块
```shell
cd /soft
mkdir /soft/nginx_lua -p
cd /soft/nginx_lua
wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz -O ngx_devel_kit-0.3.0.tar.gz
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.14.tar.gz -O lua-nginx-module-0.10.14.tar.gz

tar xf ngx_devel_kit-0.3.0.tar.gz
tar xf lua-nginx-module-0.10.14.tar.gz
```

### 编译安装nginx
具体编译方法见[centos 7 编译安装nginx1.12.1](https://www.fushisanlang.cn/2021/02/09/note/nginx/centos%207%20%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85nginx1.12.1%E5%B9%B6%E5%8A%A0%E8%BD%BDnginx_upstream_check_module%E6%A8%A1%E5%9D%97/)
这里不多做赘述

需要注意的是，因为要加装lua模块，所以在编译时要增加相关的模块
```shell
 ./configure --prefix=/usr/local/nginx --user=www --group=www \
 --with-http_stub_status_module --with-http_ssl_module \
 --without-mail_pop3_module --without-mail_smtp_module \
 --without-mail_imap_module --add-module=/soft/nginx_new/naxsi-master/naxsi_src \
 --add-module=/soft/nginx_new/nginx-limit-upstream-master \
 --add-module=/soft/nginx_new/nginx-upstream-jvm-route-master \
 --add-module=/soft/nginx_new/ngx_http_proxy_connect_module-master \
 --with-http_v2_module --add-module=/soft/nginx_lua/ngx_devel_kit-0.3.0 \
 --add-module=/soft/nginx_lua/lua-nginx-module-0.10.14
```

### 测试nginx的lua模块
```
vim /usr/local/nginx/conf/nginx.conf
    #在server 段中添加
    location /luatest {
        default_type text/html;
        content_by_lua_block {
            ngx.say(helloworld)
        }
    }

systemctl reload nginx #重新加载nginx配置

#如果提示缺少 libluajit-5.1.so.2文件，则需要给 libluajit-5.1.so.2添加一个软连接
ln -s /usr/local/luajit/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2

curl http://xxxx/luatest #如果上述步骤无误，访问结果为helloworld
```

## 使用skywalking-nginx-lua将链路信息发给skywalking

### 下载skywalking-nginx-lua
```
mkdir -p /soft/skywalking-nginx-lua
wget https://mirrors.tuna.tsinghua.edu.cn/apache/skywalking/nginx-lua/0.3.0/skywalking-nginx-lua-0.3.0-src.tgz
tar xf skywalking-nginx-lua-0.3.0-src.tgz
```

### 安装cjson
试验了多个版本的cjson，在使用时均有问题，后来在openresty中找到了合适的cjson，故这里直接使用编译产物，不重新安装
```shell
cd /usr/local/luajit/lib/lua/5.1
wget https://download.fushisanlang.cn/cjson.so
```

### 配置nginx
```shell
#skywalking-nginx-lua 提供了示例用的配置文件 /soft/skywalking-nginx-lua/examples/nginx.conf
#如果是新部署的nginx可以直接使用相应的配置进行部署
#如果是其他的配置，则要在nginx.conf中添加相应配置，具体配置如下：

#在http段添加
    lua_package_path "/soft/skywalking-nginx-lua/lib/?.lua;;";
    # Buffer represents the register inform and the queue of the finished segment
    lua_shared_dict tracing_buffer 100m;

    # Init is the timer setter and keeper
    # Setup an infinite loop timer to do register and trace report.
    init_worker_by_lua_block {
        local metadata_buffer = ngx.shared.tracing_buffer

        metadata_buffer:set('serviceName', 'jiashicang_nginx3')
        -- Instance means the number of Nginx deloyment, does not mean the worker instances
        metadata_buffer:set('serviceInstanceName', 'jiashicang_nginx_43_3')

        require("skywalking.client"):startBackendTimer("http://172.19.32.42:12800")
    }

#在server的location段添加
    proxy_pass http://127.0.0.1:38080/; #正常代理配置
    proxy_http_version 1.1; #正常代理配置
    proxy_set_header Host zy.e-nci.com; #正常代理配置
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; #正常代理配置
    proxy_connect_timeout   300; #正常代理配置
    proxy_set_header X-Real-IP $remote_addr; #正常代理配置
      default_type text/html;
    rewrite_by_lua_block {
        require("skywalking.tracer"):start("upstream service")
    }
    body_filter_by_lua_block {
        if ngx.arg[2] then
            require("skywalking.tracer"):finish()
        end
    }

    log_by_lua_block {
        require("skywalking.tracer"):prepareForReport()
    }

```
