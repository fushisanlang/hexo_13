---
title: auto_install_freeswitch.sh
date: 2022-7-12
tags:
  - shell
categories:
  - demo
abbrlink: 20c265dc
---

```shell
#!/bin/bash
#for install freeswitch

package_dir='/tmp/data/'
install_dir='/usr/local/'
logfile=${package_dir}install.log

mkdir -p ${package_dir}
> ${logfile}

#date +%F\ %H:%M:%S >> ${logfile}
#echo 'start conf firewalld and selinux' >> ${logfile}
#
#setenforce 0
#systemctl stop firewalld
#systemctl disable firewalld
#sed 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux -i

date +%F\ %H:%M:%S >> ${logfile}
echo 'start mkdir datadir and get install package' >> ${logfile}
#a command to get install package as:
cp /tmp/freeswitch-1.6.20.tar.bz2 /tmp/mysql80-community-release-el7-3.noarch.rpm /tmp/modules.conf ${package_dir}


date +%F\ %H:%M:%S >> ${logfile}
echo 'start install dependencies' >> ${logfile}
yum install epel-release http://files.freeswitch.org/freeswitch-release-1-6.noarch.rpm -y
rpm -ivh ${package_dir}mysql80-community-release-el7-3.noarch.rpm
yum install -y git alsa-lib-devel autoconf automake bison broadvoice-devel bzip2 curl-devel db-devel e2fsprogs-devel flite-devel g722_1-devel gcc-c++ gdbm-devel gnutls-devel ilbc2-devel ldns-devel libcodec2-devel libcurl-devel libedit-devel libidn-devel libjpeg-devel libmemcached-devel libogg-devel libsilk-devel libsndfile-devel libtheora-devel libtiff-devel libtool libuuid-devel libvorbis-devel libxml2-dev el lua-devel lzo-devel mongo-c-driver-devel ncurses-devel net-snmp-devel openssl-devel opus-devel pcre-devel perl perl-ExtUtils-Embed pkgconfig portaudio-devel postgresql-devel python26-devel python-devel soundtouch-devel speex-devel sqlite-devel unbound-devel unixODBC-devel wget which yasm zlib-devel
yum install libshout libshout-devel -y
yum install lame lame-devel mpg123 mpg123-devel -y
yum install unixODBC unixODBC-devel libtool-ltdl libtool-ltdl-devel -y
yum install mysql-connector-odbc -y
yum install sems sems-speex -y

date +%F\ %H:%M:%S >> ${logfile}
echo 'start install freeswitch' >> ${logfile}
tar xf ${package_dir}freeswitch-1.6.20.tar.bz2 -C ${package_dir}
mv -f ${package_dir}modules.conf ${package_dir}freeswitch-1.6.20/
cd ${package_dir}freeswitch-1.6.20

date +%F\ %H:%M:%S >> ${logfile}
echo 'start configure' >> ${logfile}
./configure 
date +%F\ %H:%M:%S >> ${logfile}
echo 'start make' >> ${logfile}
make 
date +%F\ %H:%M:%S >> ${logfile}
echo 'start make install' >> ${logfile}
make install 

date +%F\ %H:%M:%S >> ${logfile}
echo 'all done.' >> ${logfile}

clear
cat ${logfile}
```