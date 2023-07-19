---
title: rhcsa模拟题答案
date: 2020-6-1
updated: 2020-6-2
tags:
  - rhcsa
  - exam
categories:
  - note
abbrlink: 71e7f679
---
# rhcsa 

### change root passwd
```shell
touch /.autorelabel
```

### setenforce
```shell
```

### change hostname
```shell
```

### change ip
```shell
```

### make yum repo
```shell
```

### change lvs
```shell
umount /dev/mapper/vg0-vo 
e2fsck -f /dev/mapper/vg0-vo
resize2fs /dev/mapper/vg0-vo 230M
lvreduce -L 230M  /dev/vg0/vo 
mount -a

lvextend -L 400M /dev/vg0/vo
resize2fs /dev/vg0/vo  #ext4 filesystem
xfs_growfs /dev/vg0/vo  #xfs filesystem
```

### manage user
```shell

groupadd sysmgrs 
useradd -G sysmgrs natasha 
useradd -G sysmgrs harry
useradd -s /sbin/nologin sarah
passwd sarah
```

### manage file 
```shell
cp /etc/fstab  /var/tmp/
ll /var/tmp/fstab
setfacl  -m u:natasha:rw /var/tmp/fstab
setfacl  -m u:harry:0 /var/tmp/fstab
getfacl /var/tmp/fstab
```

### crontab
```shell
crontab -e -u natasha
cat /var/spool/cron/natasha 
systemctl status crond.service
systemctl enable crond.service
```

### manage folder 
```shell
mkdir /home/managers 
ll -d /home/managers
chgrp sysmgrs /home/managers 
chmod 770 /home/managers
chmod g+s /home/managers
ll -d /home/managers

```

### update kernel
```shell
rpm -ivh http://172.25.10.254/update/kernel-3.10.0-123.1.2.el7.x86_64.rpm
vim /boot/grub2/grub.cfg   /menuentry 
grub2-set-default 0
reboot
uname -r
```


### ladp
```shell
yum install authconfig-gtk.x86_64 sssd -y
authconfig-gtk #config ladp dn server tls pass_is_ldap
su - ldapuser1
```

### ntp
```shell
vim /etc/chrony.conf 
systemctl restart chronyd.service 
systemctl enable  chronyd.service 
chronyc sources -v
	
210 Number of sources = 1

  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current synced, '+' = combined , '-' = not combined,
| /   '?' = unreachable, 'x' = time may be in error, '~' = time too variable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||                                                /   xxxx = adjusted offset,
||         Log2(Polling interval) -.             |    yyyy = measured offset,
||                                  \            |    zzzz = estimated error.
||                                   |           |                         
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* classroom.example.com         8   6    17    33  -8077ms[ -98.6s] +/- 3040us
```


### autofs
```shell
yum install autofs
systemctl enable autofs
vim /etc/auto.master
	/home/guests /etc/exam.ldap
vim /etc/exam.ldap
	ldapuser1       -rw,vers=3      classroom.example.com:/home/guests/ldapuser1
systemctl restart autofs

su - ldapuser1
$ df -h
$ exit
```

### add user
```shell
useradd -u 3533 modteed
passwd modteed
```

### add swap
```shell
fdisk /dev/vdb
	n
	p
	2
	\n
	+756M
	t
	82
	wq

partprobe
mkswap /dev/vdb2 
vim /etc/fstab
	/dev/vdb2       swap    swap    defaults        0 0

swapon -a
swapon -s
free -m
```

### find file
```shell
mkdir /root/findfiles 
ll /root/findfiles/
find / -user jacques -exec cp -pr {} /root/findfiles/ \;
ll /root/findfiles/
```

### find word
```shell
grep ng /usr/share/xml/iso-codes/iso_639_3.xml | sed 's/\t//g'|sed 's/^ *//g' > /root/list
```

### tar file
```shell
tar zcvf /root/backup.tar.gz /usr/local/
```

### lvs create
```shell
fdisk /dev/vdb 
	n
	p
	\n
	\n
	+1G
	t
	\n
	8e
	w

partprobe 
pvcreate /dev/vdb3
vgcreate qagroup -s 16M /dev/vdb3
lvcreate -l 60 -n qa qagroup
mkfs.ext3 /dev/qagroup/qa 
vim /etc/fstab 
	/dev/qagroup/qa	/mnt/qa	ext3	defaults	0	0
mkdir /mnt/qa
mount -a
df -h
```
