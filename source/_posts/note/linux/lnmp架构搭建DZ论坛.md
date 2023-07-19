---
title: lnmp搭建dz论坛
date: 2020-2-10
updated: 2020-2-11
tags:
  - lnmp
  - nginx
  - mysql
  - php
categories:
  - note
abbrlink: 37b47781
---


# nginx

* 基本安装

```shell
    tar zxf nginx-1.10.1.tar.gz
    cd nginx-1.10.1
    vim auto/cc/gcc
        #注释debug
    vim src/core/nginx.h
        #取消版本号显示 保证安全 对完不显示nginx版本
    yum install gcc -y
    #因为原码使用C语言编写的，编译时需要编译器
    yum install pcre-devel -y 
    yum install openssl-devel -y #解决其他二进制依赖性
    
    ./configure --prefix=/usr/local/lnmp/nginx \
    --with-http_ssl_module \
    --with-http_stub_status_module   #编译

    make
    make install
    ln -s /usr/local/lnmp/nginx/sbin/nginx /usr/local/sbin/
    useradd -u 900 -d /usr/local/lnmp/nginx   nginx 
    nginx #开启nginx
    nginx -t #检查配置文件语法
    nginx -s reload #重新加载
    nginx -s stop #停止
    cd /usr/local/lnmp/nginx/conf/
    vim nginx.conf
        user  nginx;   #设置用户
        worker_processes  2;	#默认打开工作进程个数
        worker_cpu_affinity 01 10;	
        #设置cpu工作模式 每个worker_processes使用一个cpu
        #通过设置cou工作模式将进程与cpu绑定
        
    nginx -t
    nginx -s reload

```

<!--more-->
* 压力测试

```
    vim nginx.conf
        location /status {
            stub_status on;
            access_log off;
        }

    ab -n 300 -c 300 http://172.25.15.1/index.html   
    #-n 总请求个数 -c 并发数     
    #本句即为，一共300个并发，对172.25.15.1发送300个请求
    #访问172.25.15.1/status 
```
* https

```
    vim nginx.conf
        #去掉ssl的注释        
        server_name  server1.example.com;
        ssl_certificate_key  cert.pem;
    cd /etc/pki/tls/certs/
    make cert.pem
    mv cert.pem /usr/local/lnmp/nginx/conf/
    nginx -t   #先建立pem文件再检查语法，否则会因为缺失文件报错
    nginx -s reload
```
此时，通过https访问172.25.15.1时，会提示下载证书


* 虚拟主机

```
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
```
    #在主机的/etc/hosts 中添加解析
    #然后访问

* 负载均衡

    
    #分别打开server2,server3的http服务，配置默认发布目录

**server1**
 ```   
    vim nginx.conf
        upstream westos {     #15行 http{之后
        #此句为添加一个westos
        server 172.25.15.2:80;
        server 172.25.15.3:80;
        }
        #把之前配置的www.westos.org的默认发布文件及目录注释掉
        proxy_pass http://westos;   #此处为上文添加的westos
    nginx -t
    nginx -s reload
```
默认的负载均衡方式为循环轮矫，可以通过在某一IP后添加   

        weight=n
来增加权重

其他方式

ip_hash    
始终使用第一次使用的服务器 此方式在使用时需要添加在server之上

backup   
通过一个server ip，在后端服务器均不工作时，提供提示

        server 172.25.15.1:8080 backup;

此时需要本机（本实验的server1）的http开在8080端口   
在后端服务器工作时，本机不提供http服务   
在后端服务器不工作时，提供服务。 


* 动态模块安装
```
    
    ./configure --prefix=/tmp/nginx \
    --with-http_perl_module=dynamic \
    --with-mail=dynamic   #在此处添加的是所有想要的模块
    yum install perl-ExtUtils-Embed -y
    vim conf/nginx.conf
	    load_module "modules/ngx_http_perl_module.so";  
	    #10行   此处添加的时需要使用的模块
```
***注意 因为之前安装过ungix，并且/usr/local/sbin/ungix连接的是之前安装时的命令。***

***所以在使用时，应该使用/tmp/nginx/sbin/下的nginx命令。***


# mysql

*　软件安装
```
    #编译
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
    #安装目录
    -DMYSQL_DATADIR=/usr/local/mysql/data \
    #数据库存放目录
    -DMYSQL_UNIX_ADDR=/usr/local/mysql/data/mysql.sock \ 
    #Unix socket 文件路径
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    #安装 myisam 存储引擎
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    #安装 innodb 存储引擎
    -DDEFAULT_CHARSET=utf8 \
    #使用 utf8 字符
    -DDEFAULT_COLLATION=utf8_general_ci \
    #校验字符
    -DEXTRA_CHARSETS=all \
    #安装所有扩展字符集

    #期间可能会因为依赖性报错。
    #此时需要安装依赖性。
    #安装之后，要删除CMakeCatah.txt。此文件是编译中的缓存文件，
    #如果不删除会在上次的基础上继续编译。之前安装的依赖性不会被识别。

    make
    make install
```
    #注意
    #安装过程因为是在虚拟机中进行，所以可能会有虚拟机磁盘空间不足的问题
    #需要通过lvm方式拉伸虚拟机磁盘空间。
    #在虚拟机管理中，
    #为虚拟机添加20G的虚拟磁盘。
    #然后在虚拟机的操作系统中。
    #为新加入的磁盘分区。 
    fdisk -cu /dev/vdb
    #分区后，将vdb1的类型改为8e。
    #然后进行root的扩容。
    pvcreate /dev/vdb1
    vgextend VolGroup /dev/vdb1   
    #此处的VolGroup时root所在的逻辑卷组，可以通过vgs命令查询。
    lvextend -L +20G /dev/VolGroup/lv_root    
    #此时可能出现可用空间不足的错误，可以通过添加pe个数的方式扩容
    #具体可用pe个数会在报错中显示
    lvextend -l +5119 /dev/VolGroup/lv_root  
    #此时，在逻辑层面完成了root的扩容，但是文件系统并未识别扩容。
    resize2fs /dev/VolGroup/lv_root    
    #此时，通过 df -sh命令，可以看见root的大小增加了20g。




* 初始化

```
    useradd -u 27 -M -d /usr/local/lnmp/mysql/data -s /sbin/nologin mysql    
    #为mysql创建用户，如果通过rpm安装，会自动创建此用户
    groupmod -g 27 mysql
    cd /usr/local/lnmp/mysql/
    chown mysql.mysql . -R
    cd /etc/
    mv my.cnf my.cnf.bck      #备份
    cd -
    cd support-files/
    cp my-default.cnf /etc/my.cnf
    cp mysql.server /etc/init.d/mysqld
    cd ..
    cd bin/
    pwd
    vim .bash_profile         
        #为环境添加命令地址添加之后，可以直接补齐
        #在环境中添加bin地址
    source .bash_profile 
    mysqld --initialize --user=mysql   #获得一个初始密码
    cd /usr/local/lnmp/mysql/
    chown root . -R
    chown mysql data/ -R
    /etc/init.d/mysqld start
    mysql -p
        >alter user root@localhost identified by 'yierer333';   
        #更改密码
```
# PHP

* 编译

```
    tar jxf php-5.6.20.tar.bz2 
    yum install re2c-0.13.5-1.el6.x86_64.rpm 
    yum install libmcrypt-* -y

    ./configure --prefix=/usr/local/lnmp/php \
    --with-config-file-path=/usr/local/lnmp/php/etc \
    --with-openssl --with-snmp --with-gd \
    --with-zlib --with-curl \
    --with-libxml-dir --with-png-dir --with-jpeg-dir \
    --with-freetype-dir  --with-gettext --without-pear \
    --with-gmp --enable-inline-optimization --enable-soap \
    --enable-ftp --enable-sockets --enable-mbstring \
    --with-mysql --with-mysqli --with-pdo-mysql \
    --enable-mysqlnd --enable-fpm --with-fpm-user=nginx \
    --with-fpm-group=nginx --with-mcrypt --with-mhash

    make
    make install
```
* 配置

```
    cd /usr/local/lnmp/php
    cd etc/
    cp php-fpm.conf.default php-fpm.conf
    cd /mnt/php-5.6.20/
    cp php.ini-production /usr/local/lnmp/php/etc/php.ini
    cd  /usr/local/lnmp/php/etc/
    vim php.ini 
        #在socket位置条目增加/usr/local/lnmp/mysql/data/mysql.sock  
        #一共有三条
    cd /usr/local/lnmp/php/etc/
    vim php-fpm.conf
        #25行 取消注释
    cd /mnt/php-5.6.20/sapi/fpm/
    cp init.d.php-fpm /etc/init.d/php-rpm
    chmod +x /etc/init.d/php-rpm
    /etc/init.d/php-rpm start
    cd /usr/local/lnmp/nginx/conf/
    vim nginx.conf
        location /    模块中，添加默认发布文件index.php
        location ~ \.php$ {   #取消注释更改include指定文件
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
            include        fastcgi.conf;
        }
    nginx -t #检查语法
    nginx  #启动nginx
    cd ..
    cd html/
    vim index.php
        <?php
            phpinfo()
        ?>
    #此时通过访问172.25.15.1
    #即可查看关于php的内容，而非index.php文件的内容和

```

# 配置论坛
```

    unzip Discuz_X3.2_SC_UTF8.zip -d /usr/local/lnmp/nginx/html
    cd /usr/local/lnmp/nginx/html
    chmod 777 . -R
    mysql -p 3登陆数据库
        > alter user root@localhost identifid by 'yierer333';           #为论坛数据库新建账户，授权以及设置密码
        >flush privileges; #刷新
    cd /usr/local/lnmp/mysql/ 
    chmod 777 data -R    #使zy用户可以写数据库
    #通过浏览器访问172.25.15.1/upload进行论坛配置


```



