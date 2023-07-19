---
title: nginx源码安装及简单配置
date: 2016-1-1
updated: 2016-1-2
tags:
  - nginx
categories:
  - note
abbrlink: 20f8d8b9
---
# nginx 

### 安装

    tar zxf nginx-1.10.1.tar.gz
    cd nginx-1.10.1
    vim auto/cc/gcc
	    # 注释debug
    vim src/core/nginx.h
	    # 取消版本号显示

    yum install gcc openssl-devel pcre-devel  -y 
    ./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_stub_status_module  #编译
    make
    make install

    ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/
    useradd -u 900 -d /usr/local/nginx   nginx 
    nginx #开启nginx
    nginx -t #检查配置文件语法
    nginx -s reload #重新加载
    nginx -s stop #停止
    cd /usr/local/nginx/conf/
    vim nginx.conf
	    user  nginx;   #设置用户
	    worker_processes  2;	#默认打开工作进程个数
	    worker_cpu_affinity 01 10;	#设置cpu工作模式

    nginx -t
    nginx -s reload


### 压力测试


    vim nginx.conf
        location /status {
                stub_status on;
                access_log off;
        }

    ab -n 300 -c 300 http://172.25.15.1/index.html   #-n 总请求个数 -c 并发数       
    # 本句即为，一共300个并发，对172.25.15.1发送300个请求
    访问172.25.15.1/status 

### ssl

    vim nginx.conf
	    # 去掉ssl的注释        
	    server_name  server1.example.com;
	    ssl_certificate_key  cert.pem;

    cd /etc/pki/tls/certs/
    make cert.pem
    mv cert.pem /usr/local/nginx/conf/
    nginx -t   #先建立pem文件再检查语法，否则会因为缺失文件报错
    nginx -s reload
    此时，通过https访问172.25.15.1时，会提示下载证书


### 虚拟主机

    vim nginx.conf
    	server {
    		listen 80;
    		server_name www.westos.org;

    		location / {
    		root /web1;
    		index index.html;
        	}
    	}

    nginx -t
    mkdir /web1
    cd /web1/
    vim index.html
	    hello westos.org
    nginx -s reload

    在主机的/etc/hosts 中添加解析， 然后访问

### 负载均衡

    分别打开server2,server3的http服务，配置默认发布目录
    
    在server1上
    vim nginx.conf
        upstream westos {     #15行 http{之后  #此句为添加一个westos
        server 172.25.15.2:80;
        server 172.25.15.3:80;
	}
	把之前配置的www.westos.org的默认发布文件及目录注释掉
	        proxy_pass http://westos;   #此处为上文添加的westos


    nginx -t
    nginx -s reload

    默认的负载均衡方式为循环轮矫，可以通过在某一IP后添加
    weight=n
    来增加权重

    其他方式
    ip_hash 
    始终使用第一次使用的服务器 此方式在使用时需要添加在server之上
    backup   
    通过一个server ip，在后端服务器均不工作时，提供提示，
    server 172.25.15.1:8080 backup;
    此时需要本机（本实验的server1）的http开在8080端口
    在后端服务器工作时，本机不提供http服务
    在后端服务器不工作时，提供服务。 


### 动态模块安装

    ./configure --prefix=/tmp/nginx --with-http_perl_module=dynamic --with-mail=dynamic   #在此处添加的是所有想要的模块
    yum install perl-ExtUtils-Embed -y
    vim conf/nginx.conf
	    load_module "modules/ngx_http_perl_module.so";  #10行   此处添加的是需要使用的模块

    注意 因为至之前安装过nginx，并且/usr/local/sbin/nginx连接的是之前安装时的版本。
    所以在使用时，应该使用/tmp/nginx/sbin/下的nginx命令。
