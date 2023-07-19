---
title: rhce模拟题答案
date: 2017-7-24
updated: 2017-7-25
tags:
  - rhce
  - exam
categories:
  - note
abbrlink: f1d60fc5
---
rhce.md

1.selinux
```
```

2.配置 ssh 访问
```
host -l my133.org
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -s 192.168.0.0/24 -p tcp --dport 22 -j REJECT
systemctl restart firewalld.service 

firewall-cmd --direct --get-all-rules 
	ipv4 filter INPUT 1 -s 192.168.0.0/24 -p tcp --dport 22 -j REJECT
```

```
check
 ifconfig eth0:0 192.168.0.111/24 #add ip
 ping ok
 ssh wrong 
```

3.自定义用户环境
```
echo "alias qstat='/bin/ps -Ao pid,tt,user,fname,rsz'" >> /etc/bashrc
source /etc/bashrc
```

4.配置端口转发
``` 
yum install httpd
systemctl enable httpd
systemctl start httpd
firewall-cmd --permanent --add-source=172.25.10.0/24 --zone=trusted
systemctl restart firewalld
firewall-cmd --list-all --zone=trusted
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 1 -s 172.25.10.0/24 -p tcp --dport 5423 -j DNAT --to-dest :80
systemctl restart firewalld
firewall-cmd --direct --get-all-rules
```

5.配置链路聚合
server
```   
nmcli connection add con-name team0 ifname team0 type team config '{"runner":{"name":"activebackup"}}' ip4 172.16.10.65/24
nmcli connection add con-name eth1 ifname eth1 type team-slave master team0
nmcli connection add con-name eth2 ifname eth2 type team-slave master team0
```


desktop
```   
nmcli connection add con-name team0 ifname team0 type team config '{"runner":{"name":"activebackup"}}' ip4 172.16.10.75/24
nmcli connection add con-name eth1 ifname eth1 type team-slave master team0
nmcli connection add con-name eth2 ifname eth2 type team-slave master team0
```

6.配置 ipv6 地址
server
```
nmcli connection show
nmcli connection modify "System eth0" ipv6.method manual ipv6.addresses 2018:ac18::11a/64
nmcli connection reload
systemctl restart network
nmcli connection up "System eth0"
nmcli connection show
ping6 2018:ac18::11b
```
desktop
```
nmcli connection show
nmcli connection modify "System eth0" ipv6.method manual ipv6.addresses 2018:ac18::11b/64
nmcli connection reload
systemctl restart network
nmcli connection up "System eth0"
nmcli connection show
ping6 2018:ac18::11b
```
7.postfix
```
vim /etc/postfix/main.cf
	myhostname = server10.example.com :75
	mydomain = example.com :83
	myorigin = $mydomain :98
	inet_interfaces = localhost #no change
	mydestination = :164
	relayhost = classroom.example.com :313
   
systemctl enable postfix
systemctl restart postfix

mail hal
#test_url:http://classroom.example.com/exam_mail/hal.txt 
```



8.samba 

server
```
yum install samba samba-common samba-client -y
vim /etc/samba/smb.conf

	workgroup = STAFF   #change 
        [common]       #add
        path = /groupdir
        host allow = 172.25.10. 127.
        browseable = yes

mkdir /groupdir
systemctl enable smb.service 
systemctl restart smb.service 
useradd -s /sbin/nologin barney
smbpasswd -a barney
pdbedit -L
semanage fcontext -a -t samba_share_t '/groupdir(/.*)?' 
restorecon -RvvF /groupdir/
touch /groupdir/file
systemctl restart smb.service 
smbclient -L //172.25.10.11 -U barney
rm -fr /groupdir/file
```

client
```
yum install samba-client

smbclient -L //172.25.10.11 -U barney
smbclient //172.25.10.11/common -U barney
 
```


9.samba 2

server
```
mkdir /data
semanage fcontext -a -t samba_share_t '/data(/.*)?' 
restorecon -RvvF /data/
vim /etc/samba/smb.conf
        [data]  #add
        path = /data
        host allow = 172.25.10. 127.
        browseable = yes
        white list = wolferyne
        read list = manager

systemctl restart smb.service 
useradd -s /sbin/nologin wolferyne
useradd -s /sbin/nologin manage
smbpasswd -a wolferyne
smbpasswd -a manage
pdbedit -L
setfacl -m u:wolferyne:rwx /data/
```




client
```
yum install cifs-utils -y
vim /root/exam
	username=manage
	password=westos
chmod 600 /root/exam
mkdir /mnt/westos
vim /etc/fstab 
	//172.25.10.11/data /mnt/westos cifs defaults,credentials=/root/exam,sec=ntlmssp,multiuser 0 0
mount -a

cifscreds add -u wolferyne 172.25.10.11
``` 


nfs

server 
```
yum install nfs-utils
vim /etc/exports
	/public 172.25.10.0/24(ro,async)
	/protected      172.25.10.0/24(rw,async,sec=krb5p)

mkdir /public
mkdir /protected/restricted -p


wget http://classroom.example.com/pub/keytabs/server10.keytab -O /etc/krb5.keytab

systemctl start nfs-server
systemctl start nfs-secure-server
systemctl enable nfs-secure-server
systemctl enable nfs-server

chmod 777 /protected/restricted/
exportfs -rv
```


clients
``` 
mkdir /mnt/nfsmount
mkdir /mnt/nfssecure
showmount -e 172.25.10.11
wget http://classroom.example.com/pub/keytabs/desktop10.keytab -O /etc/krb5.keytab

vim /etc/fstab 
	172.25.10.11:/public /mnt/nfsmount nfs defaults 0 0
	172.25.10.11:/protected /mnt/nfssecure nfs defaults,sec=krb5p 0 0

systemctl start nfs-secure
systemctl enable nfs-secure

mount -a
showmount -e 172.25.10.11

yum install authconfig-gtk.x86_64 sssd
```

web

server
```
yum install httpd
wget http://classroom.example.com/pub/materials/station.html -O /var/www/html/index.html
cd /etc/httpd/conf.d
vim exam.conf
	<VirtualHost *:80>
    	DocumentRoot "/var/www/html"
    	ServerName server10.example.com
	</VirtualHost>
systemctl enable httpd
systemctl restart httpd

yum -y install mod_ssl
vim /etc/httpd/conf.d/ssl.conf 
	:59
	:60
	:100
	:107

wget http://classroom.example.com/pub/tls/certs/westos.crt -O /etc/pki/tls/certs/server10.crt
wget http://classroom.example.com/pub/tls/private/westos.key -O /etc/pki/tls/private/server10.key
systemctl restart httpd

mkdir -p /var/www/virtual
cd /etc/httpd/conf.d
vim exam2.conf
	<VirtualHost *:80>
	    DocumentRoot "/var/www/virtual"
	    ServerName www10.example.com
	</VirtualHost>
useradd barney
setfacl -m u:barney:rwx /var/www/virtual

mkdir /var/www/virtual/confidential
mkdir /var/www/html/confidential
wget http://classroom.example.com/pub/materials/private.html -O /var/www/html/confidential/index.html
wget http://classroom.example.com/pub/materials/private.html -O /var/www/virtual/confidential/index.html
cd /etc/httpd/conf.d/
vim exam3.conf
	<Directory /var/www/html/confidential>
	    Require local
	    Require all denied
	</Directory>
	
	<Directory /var/www/virtual/confidential>
	    Require local
	    Require all denied
	</Directory>


yum install mod_wsgi
cd /etc/httpd/conf.d
cp exam.conf exam4.conf
vim exam4.conf
	Listen 8989
	<VirtualHost *:8989>
	    DocumentRoot "/var/www/html"
	    ServerName server10.example.com
	    WSGIScriptAlias / /var/www/html/webapp.wsgi
	</VirtualHost>

wget http://classroom.example.com/pub/materials/script.wsgi -O /var/www/html/webapp.wsgi

semanage port -a -t http_port_t -p tcp 8989
systemctl restart httpd

```

shell
```
vim /root/scripts.sh
	#!/bin/bash
	case $1 in
		all)
		echo none
		;;
		none)
		echo all
		;;
		*)
		echo "/root/scripts.sh none|all"
	esac
chmod +x /root/scripts.sh
```

iscsi

server
```
yum install targetcli -y
fdisk /dev/vdb
partprobe 
pvcreate /dev/vdb1
vgcreate exam /dev/vdb1
vgdisplay
lvcreate -l 767 -n iscsi_data exam
 
targetcli
	/> /backstores/block create iscsi_data /dev/exam/iscsi_data 
	/> iscsi/ create iqn.2014-11.com.example:server10
	/> /iscsi/iqn.2014-11.com.example:server10/tpg1/luns create /backstores/block/iscsi_data 
	/> iscsi/iqn.2014-11.com.example:server10/tpg1/acls create iqn.2014-11.com.example:desktop10
	/> iscsi/iqn.2014-11.com.example:server10/tpg1/portals create 172.25.10.11
	/> exit
systemctl start target	
systemctl enable target.service
```

client
```
vim /etc/iscsi/initiatorname.iscsi 
	InitiatorName=iqn.2014-11.com.example:desktop10

systemctl restart iscsid
systemctl restart iscsi
systemctl enable iscsid
systemctl enable iscsi

iscsiadm -m discovery -t st -p server10.example.com
iscsiadm -m node -T iqn.2014-11.com.example:server10
iscsiadm -m node -T iqn.2014-11.com.example:server10 -l	

fdisk  /dev/sda
mkfs.xfs /dev/sda1
blkid /dev/sda1 >> /etc/fstab
vim /etc/fstab
	UUID=4e643d52-4404-49e2-b6ce-329104313b2a       /mnt/data       xfs     defaults,_netdev 0 0

mkdir /mnt/data
mount -a	
```

maridb
```
yum install mariadb-server mariadb
systemctl enable mariadb
systemctl start mariadb
mysql_secure_installation 
mysql -p
	> create database Contacts;

wget http://classroom.example.com/pub/materials/users.mdb
mysql -p Contacts < users.mdb

mysql -p
	> create user Luigi@localhost identified by 'westos';
	> grant select on Contacts.* to Luigi@localhost;

select date @ DB	
```

https://www.yangxiaojia.me/linux/8.html