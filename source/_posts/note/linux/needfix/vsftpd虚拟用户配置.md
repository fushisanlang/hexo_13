---
title: vsftpd虚拟用户配置
date: 2017-5-18
updated: 2017-5-19
categories:
  - note
abbrlink: d64b7a0c
---
## vsftpd虚拟用户配置 

* 安装vsftpd    

```shell
yum install vsftpd -y
```

* 设置防火墙

```shell
iptables -A INPUT -p tcp -dport 21 -j ACCEPT
/etc/init.d/iptables save
#通过上述方法即可完成对vsftpd服务的匿名用户访问设置。
```


* 设置虚拟用户   

```shell
vim /etc/vsftpd/loginusers
	zhang1
	1
	zhang2
	2
	zhang3
	3						#虚拟账号及密码

db_load -T -t hash -f /etc/vsftpd/loginusers /etc/vsftpd/loginusers.db          ##加密帐号文件

vim /etc/pam.d/ckvsftpd          #创建pam文件
	account required        pam_userdb.so   db=/etc/vsftpd/loginusers    #注意DB文件不能加.db后缀
	auth    required        pam_userdb.so   db=/etc/vsftpd/loginusers

vim /etc/vsftpd/vsftpd.conf
	pam_service_name=ckvsftpd
	guest_enable=YES  
	guest_username=ftp  

mkdir /ftphome
chgrp ftp /ftphome
chmod g+s /ftphome
mkdir /ftphome/zhang{1..3}
vim /etc/vsftpd/vsftpd.conf
	local_root=/ftphome/$USER
	user_sub_token=$USER 
#此时已经完成了对于ftp匿名用户的配置，并且可以通过匿名用户访问ftp。但是匿名用户并不能在自己的家目录上传文件。并且也看不到自己家目录中的文件。   
#经过分别关闭selinux以及iptables。发现关闭防火墙后对这种现象并没有改变。但是当selinux的状态从Enforcing改为Permissive后，用户可以正常访问自己的家目录了。所以猜想此处是因为虚拟用户家目录的安全上下文的问题。


#add
pam_service_name=ckvsftpd
guest_enable=YES
guest_username=ftp
userlist_enable=YES
tcp_wrappers=YES
local_root=/data/backup/war
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
anon_umask=022
#add off


#为虚拟用户设置不同的权限
vim /etc/vsftpd/vsftpd.conf
anonymous_enable=NO    --禁止匿名用户登录
local_enable=YES       --允许本地用户登录
guest_username=virtual  --指定虚拟用户映射的账号
pam_service_name=vsftpd.vu --指定pam文件，原来默认的pam文件是vsftpd
user_config_dir=/etc/vsftpd/vusers_dir --用户独立权限配置文件的目录

mkdir /etc/vsftpd/vusers_dir
cd /etc/vsftpd/vusers_dir
vim zhang1
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
```

* 安全上下文   

```shell
chcon -t public_content_t /ftphome/ -R




getsebool -a | grep ftp
getsebool -a | grep ftp --color
setsebool -P ftp_home_dir on
setsebool -P allow_ftpd_full_access 1
```