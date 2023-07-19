---
title: centos6.7安装zabbix4
date: 2019-4-26
updated: 2019-4-27
tags:
  - zabbix
categories:
  - note
abbrlink: 14dafde
---


#### 环境说明
* centos6.7 64位
* 关闭selinux和iptables
* 使用pxc5.6.43(二进制包安装)/httpd-2.2.15(二进制包安装)/php-5.6.20(源码包编译安装)/zabbix-4.0.5(源码包编译安装)


#### 安装开发环境及常用工具
```shell
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum groupinstall "Development Tools" -y
yum install gcc c++ zip unzip man vim telnet wget nethogs htop \ 
glances dstat traceroute lrzsz goaccess ntpdate dos2unix \
openssl-devel xinetd lvm2
```

#### 安装mysql
```shell
mkdir /soft
cd /soft
wget 192.168.1.231/soft/zabbix4/Percona-XtraDB-Cluster-5.6.43-28.32-r93-el6-x86_64-bundle.tar
wget 192.168.1.231/soft/zabbix4/php-5.6.20.tar.bz2
wget 192.168.1.231/soft/zabbix4/zabbix-4.0.5.tar.gz
wget http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm
rpm -ivh percona-release-0.1-3.noarch.rpm
tar xf Percona-XtraDB-Cluster-5.6.43-28.32-r93-el6-x86_64-bundle.tar
yum install -y  Percona-XtraDB-Cluster-*
mkdir -p /data/mysql/log
chown mysql:mysql /data/mysql/log
mysql_install_db --user=mysql --datadir=/data/mysql
/etc/init.d/mysql start
mysql_secure_installation #设置mysql服务root密码
chkconfig  mysql off #关闭数据库自启动
```

#### 安装apache
```shell
yum install httpd -y
```

#### 安装php
```shell
cd /soft/
tar xf php-5.6.20.tar.bz2 
cd php-5.6.20

yum install re2c libmcrypt-* freetype-devel libevent libevent-devel  \
httpd-devel libcurl-devel libjpeg-devel libpng-devel  gmp-devel \
openldap openldap-devel net-snmp-devel pcre*  libxml2-devel -y

cp -frp /usr/lib64/libldap* /usr/lib/ 

#如果安装pcre* 报错，可以使用下述方法安装
#cd /soft/
#wget http://monkey.org/~provos/libevent-1.4.14b-stable.tar.gz
#tar xf libevent-1.4.14b-stable.tar.gz
#cd libevent-1.4.14b-stable
#./configure --prefix=/opt/libevent
#make && make install
#yum install pcre* -y

cd /soft/php-5.6.20/

./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc \
--with-openssl --with-snmp --with-gd --with-zlib --with-curl --with-libxml-dir \
--with-png-dir --with-jpeg-dir --with-freetype-dir  --with-gettext \
--without-pear --with-gmp --enable-inline-optimization --enable-soap \
--enable-ftp --enable-sockets --enable-mbstring --with-mysql --with-mysqli \
--with-pdo-mysql --enable-mysqlnd --enable-fpm   --with-mcrypt --with-mhash \
--enable-bcmath --enable-ctype --enable-session --with-ldap  --with-apxs2

make && make install

cd /usr/local/php/etc/
cp php-fpm.conf.default php-fpm.conf
cp /soft/php-5.6.20/php.ini-production /usr/local/php/etc/php.ini
vim php.ini #填写mysql socket文件路径
####/var/lib/mysql/mysql.sock

cp /soft/php-5.6.20/sapi/fpm/php-fpm /etc/init.d/
chmod +x /etc/init.d/php-fpm
```

#### 配置 httpd
```shell

vim /etc/httpd/conf/httpd.conf
    LoadModule php5_module        modules/libphp5.so
    DirectoryIndex index.php index.html index.html.var
    AddType application/x-httpd-php .php .php3 .php4 .html

vim /var/www/html/phpinfo.php 
    <?php
    phpinfo()
    ?>

/etc/init.d/httpd restart

#浏览器访问IP/phpinfo.php 确认ahache与php是否安装成功
```

#### 安装zabbix
```shell
cd /soft
tar xf zabbix-4.0.5.tar.gz
cd zabbix-4.0.5

groupadd zabbix
useradd -g zabbix zabbix

cd database/mysql

echo "create database zabbix character set utf8 collate utf8_bin;" | mysql -p
echo "grant all privileges on zabbix.* to zabbix@% identified by zabbix;" | mysql -p


mysql -uzabbix -pzabbix -Dzabbix < schema.sql
mysql -uzabbix -pzabbix -Dzabbix < images.sql
mysql -uzabbix -pzabbix -Dzabbix < data.sql

cd /soft/zabbix-4.0.5
./configure  --prefix=/usr/local/zabbix --enable-server --enable-agent \
--with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
make install

vim /usr/local/zabbix/etc/zabbix_server.conf
    DBHost=192.168.2.133
    DBName=zabbix
    DBUser=zabbix
    DBPassword=zabbix
    DBPort=3306
    ListenIP=192.168.2.133


cd /etc/init.d
wget 192.168.1.231/soft/zabbix_server
chmod +x zabbix_server

/etc/init.d/zabbix_server start

cp -pr /soft/zabbix-4.0.5/frontends/php /var/www/html/zabbix

#浏览器访问 http://192.168.2.133/zabbix/setup.php进行初始化
#按照相应建议修改php配置
vim /usr/local/php/etc/php.ini
    post_max_size = 16M
    max_execution_time = 300
    max_input_time = 300
    date.timezone = Asia/Shanghai
    always_populate_raw_post_data = -1

/etc/init.d/httpd restart

#Cannot create the configuration file.    报错
wget 192.168.1.231/soft/zabbix.conf.php
#按照相应配置修改文件

#字体乱码解决方法
mkdir -p /var/www/html/zabbix/fonts
cd /var/www/html/zabbix/fonts
mkdir bak
mv * bak
wget 192.168.1.231/soft/zabbix4/simkai.ttf 192.168.1.231/soft/zabbix4/DejaVuSans.ttf
```

