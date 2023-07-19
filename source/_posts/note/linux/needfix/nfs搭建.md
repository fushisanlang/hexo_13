---
title: nfs搭建
date: 2016-11-20
updated: 2016-11-21
categories:
  - note
abbrlink: 941a0cef
---
* 只读分享 

**server**


    yum install nfs-utils.x86_64 rpcbind-0.2.0-13.el6_9.1.x86_64 -y 
    systemctl start nfs 
    vim /etc/exports
        /share	
    172.25.15.10(ro)
    mkdir /share 
    touch /share/file{1..9} 
    exportfs -rv 刷新服务 
    systemctl stop firewalld.service 

**desktop**


    showmount -e 172.25.15.11 
    mount 172.25.15.11:/share /mnt 


* 完全分享


**server** 

    chmod 777 /share 
    vim /etc/exports 
        /share 172.25.15.10(rw,anonuid=1000,anongid=1000,no_root_squash) 
        #以uid的身份编辑文件，root用户不改变账户身份。 
    exportfs -rv 


* 加密 

两边配置Ldap 


**server**

    wget -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/server15.keytab 
    vim /etc/sysconfig/nfs 14 RPCNFSDARGS="-V 4.2" 
    systemctl restart nfs-server.service 
    systemctl start nfs-secure-server 
    vim /etc/exports 
        /share 172.25.15.10(rw,sec=krb5p) 
    exportfs -rv 

**desktop**

    wget -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/desktop15.keytab 
    systemctl start nfs-secure 
    mount -o vers=4,sec=krb5p 172.25.15.11:/share /mnt