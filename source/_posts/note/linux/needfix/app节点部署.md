---
title: app节点部署
date: 2016-10-20
updated: 2016-10-21
categories:
  - note
abbrlink: '28758278'
---
   * tomcat配置
   
 

  
    mkdir /home/ap   
    useradd -d /home/ap/tomcat -u 504 tomcat
    yum install -y nfs-utils
    showmount 192.168.1.80
    mkdir -p /home/ap/tomcat/qd_uploadFile/uploadFile
    chown tomcat:tomcat /home/ap/tomcat/qd_uploadFile/uploadFile
    chown tomcat:tomcat /home/ap/tomcat/qd_uploadFile/
    mount -t nfs -o nolock -o tcp 192.168.1.80:/home/ap/tomcat/jfpt_qd/webapps/jfpt_qd/uploadFile /home/ap/tomcat/qd_uploadFile/uploadFile/
    su - tomcat
    vim .bash_profile 
        JAVA_HOME=/usr/java/jdk1.8.0_131
        export JAVA_HOME
        CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
        export CLASSPATH
        PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
        export PATH
        export LANG=zh_CN.UTF-8
    source .bash_profile
    vim jfpt_qd/conf/server.xml

*　日志同步配置

日志服务器：192.168.1.143 


     vim /etc/rsyncd.conf
        [80-jfpt_qd]   #服务器及服务名
        path = /home/www/applelog/80/jfpt_qd/  #日志存放位置 如果是新的服务器需要创建目录。具体方法后面详述
        comment = "jfpt_qd" #服务名称
        list = yes
        read only = no
        ignore errors = yes
        hosts allow = 192.168.1.80  #服务地址
        hosts deny = *
        
    mkdir -p /home/www/applelog/80/jfpt_qd/  
    #这条命令是用来创建日志存放目录。但是80级别的目录需要使用www账户登录，然后要注意目录的asl权限列表，具体使用时可以通过history命令查看之前的方法
    setfacl  -m u:tomcat:rwx 61
    
客户端配置

    rpm -qa | grep rsync  #检查是否安装rsync  没安装的话应先安装
    vim /etc/rsyncd.secret   
        rsync
    chmod 600 /etc/rsyncd.secret      
    #如果该主机之前配置过日志同步，则该文件应该已经存在，但是因为权限，可能无法打开，所以只要文件存在就好
    rsync -av /home/ap/tomcat/ccbsncom-1400/logs/ rsync@192.168.1.143::86-ccbsncom-1400 --password-file=/etc/rsyncd.secret  
    #手工验证，在143上有日志生成的话，即表示配置无误
    rsync -av /home/ap/tomcat/jfpt_qd_2/logs/ rsync@192.168.1.143::60-jfpt_qd_2 --password-file=/etc/rsyncd.secret
    crontab -e
        */5 * * * * rsync -av /home/ap/tomcat/jfpt_qd/logs/ rsync@192.168.1.143::80-jfpt_qd --password-file=/etc/rsyncd.secret 
        #每五分钟默认同步日志。设置好后  可以在十分钟左右查看日志，如果143上的日志生成时间与最开始不同，则代表配置无误。
