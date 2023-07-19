---
title: Mariadb安装与使用
tags:
  - Mariadb安装与使用
categories:
  - note
abbrlink: 2a914c5b
date: 2021-07-04 00:00:00
updated: 2021-07-04 00:00:00
---




### 安装    

        yum install mariadb mariadb-server.x86_64 -y

### 关闭网络端口   

        vim /etc/my.cnf
        skip-networking=1 
    netstat -antlpe | grep mysql # 查看Mariadb使用的端口 
    systemctl restart mariadb   
<!--more-->
### 初始化 

    mysql_secure_installation 
        # 输入新密码 所有都选择yes   
### 使用 

    mysql -u root -p	#密码 
    SHOW DATABASES;	 #查看存在的库 
    CREATE DATABASE linux;	#新建name库 
    USE linux;	#使用name库 
    SHOW TABLES;	#显示已有表格 
    CREATE TABLE name （ #有一个空格 username varchar(10) not null, password varchar(30) not null, age varchar(3) );	  #新建表格 
    DESC name;	#显示表格属性 
    INSERT INTO name VALUES (‘user1’,’123’,’12’);	#添加数据
    SELECT * FROM name;   #显示数据 
    UPDATE name SET AGE='30' WHERE username='user2';   #更新数据 
    DELETE FROM name WHERE username='user1';   #删除某行
    ALTER TABLE name ADD sex varchar(4);   #添加字段 
    ALTER TABLE name DROP sex;    #删除字段
    ALTER TABLE name ADD sex varchar(4) AFTER password;	   #在某字段后添加另一字段 
    DROP TABLE name;	#删除表格
    DROP DATABASE linux;     #删除库

### 备份还原 
##### 备份 

    mysqldump -u root -predhat westos   #备份westos库 
    mysqldump -u root -predhat --all-databases #备份所有库 
    mysqldump -u root -predhat westos > /mnt/westos.sql #把westos库备份为/mnt/westos.sql 

##### 还原 

    mysql -u root -predhat -e ”create database westos;”    #新建westos库 
    mysql -u root -predhat < /mnt/westos.sql    #把/mnt/westos.sql还原为westos库   
### 密码 

##### 已知密码 

    mysqladmin -uroot -predhat passwd westos   #更改密码 
    
##### 未知密码 

    systemctl stop mariadb
    myaqld_safe --skip-grant &    #跳过认证 mysql 进入数据库 
    UPDATE mysql.user SET Passwd=passwd('westos') WHERE User='root'; #改变密码 
    ps aux | grep mysql #查看有关进程 
    kill -9 XXXX   #关闭有关进程 
    systemctl start mariadb  #重启数据库 
    
### 用户管理 

    CREATE USER zhang@'localhost' identified by 'redhat'; #创建用户
    SELECT User FROM mysql.user;  #查看已有用户 
    GRANT SELECT on westos.* to zhang@localhost;  #用户授权 
    SHOW GRANTS FOR zhang@localhost;   #查看用户权限 
    REVOKE DELETE on westos.* FROM zhang@localhost;  #删除用户权限 
    DROP USER zhang@localhost;  #删除用户   

### 图形服务 

    yum install httpd php-mysql.x86_64 php -y  #安装软件 
    mv phpMyAdmin-3.4.0-all-languages.tar.bz2 /var/www/html/  #移动压缩包到http根目录 
    tar jxf phpMyAdmin-3.4.0-all-languages.tar.bz2  #解压 
    rm -fr phpMyAdmin-3.4.0-all-languages.tar.bz2  #删除压缩包 
    mv phpMyAdmin-3.4.0-all-languages 123  #改名 
    cd 123/  #进入图形目录 
    cp config.sample.inc.php config.inc.php  #生成配置文件 
    vim config.inc.php #更改配置文件
        $cfg['blowfish_secret'] = 'cookie'; #添加cookie值 
    systemctl restart httpd #重启httpd
