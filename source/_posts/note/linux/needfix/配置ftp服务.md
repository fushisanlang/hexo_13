---
title: 配置ftp服务
date: 2018-10-3
updated: 2018-10-4
categories:
  - note
tags:
  - ftp
abbrlink: bd4a9c44
---
```shell
    vim /etc/sysconfig/selinux
        SELINUX=disabled
    reboot

    yum install vsftpd.x86_64  -y 
    systemctl start vsftpd
    systemctl enable vsftpd
    yum install lftp -y
        firewall-cmd --permanent --add-service=ftp
        firewall-cmd --reload
```

* 匿名用户服务

```shell   
    vim /etc/vsftpd/vsftpd.conf     ##ftp服务配置文件
        anonymous_enable=YES|NO		##匿名用户登陆限制


    vim /etc/vsftpd/vsftpd.conf
        write_enable=YES
        anon_upload_enable=YES
        chgrp ftp /var/ftp/pub
        chmod 775 /var/ftp/pub    #<匿名用户上传>

        anon_root=/direcotry         #<匿名用户家目录修改>

        anon_umask=xxx    
        #<匿名用户上传文件默认权限修改> 参考chmod预留权限

        anon_mkdir_write_enable=YES|NO    #<匿名用户建立目录>

        anon_world_readable_only=YES|NO 
        #<匿名用户下载>设定参数值为no表示匿名用户可以下载

        anon_other_write_enable=YES|NO	  #<匿名用户删除>

        chown_uploads=YES
        chown_username=student   #<匿名用户使用的用户身份修改>

        anon_max_rate=102400    #<最大上传速率>

        max_clients=2   #<最大链接数>
```

* 本地用户配置
    
```shell
    vim /etc/vsftpd/vsftpd.conf
        local_enable=YES|NO		##本地用户登陆限制
        write_enable=YES|NO		##本地用户写权限限制
        
        local_root=/directory  #<本地用户家目录修改>

        local_umask=xxx   #<本地用户上传文件权限>

        chroot_local_user=YES    #<限制本地用户浏览/目录>
    
    chmod u-w /home/*         #所有用户被锁定到自己的家目录中

    vim /etc/vsftpd/vsftpd.conf    
        chroot_local_user=NO     #用户黑名单建立
        chroot_list_enable=YES
        chroot_list_file=/etc/vsftpd/chroot_list

        chroot_local_user=YES    #用户白名单建立
        chroot_list_enable=YES
        chroot_list_file=/etc/vsftpd/chroot_list

    vim /etc/vsftpd/ftpusers		##用户黑名单
    vim /etc/vsftpd/user_list		##用户临时黑名单

    vim /etc/vsftpd/vsftpd.conf
        userlist_deny=NO                #用户白名单设定
        /etc/vsftpd/user_list			        
        #参数设定，此文件变成用户白名单，只在名单中出现的用户可以登陆ftp
```
* 虚拟帐号配置独立   

```shell
    vim /etc/vsftpd/vsftpd.conf
        #注释或者删除所有匿名账户设置
        user_config_dir=/etc/vsftpd/userconf
    mkdir -p /etc/vsftpd/userconf
    vim /etc/vsftpd/userconf/user1       
        #在此文件中单独配置user1的权限，此文件的优先级高。
```