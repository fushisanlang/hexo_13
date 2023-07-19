---
title: freeswitch安装
date: 2017-1-23
updated: 2017-1-24
categories:
  - note
abbrlink: 77980b25
---
# freeswitch 安装

```shell
yum install -y http://files.freeswitch.org/freeswitch-release-1-6.noarch.rpm epel-release
yum install -y git alsa-lib-devel autoconf automake bison broadvoice-devel bzip2 curl-devel db-devel e2fsprogs-devel flite-devel g722_1-devel gcc-c++ gdbm-devel gnutls-devel ilbc2-devel ldns-devel libcodec2-devel libcurl-devel libedit-devel libidn-devel libjpeg-devel libmemcached-devel libogg-devel libsilk-devel libsndfile-devel libtheora-devel libtiff-devel libtool libuuid-devel libvorbis-devel libxml2-dev el lua-devel lzo-devel mongo-c-driver-devel ncurses-devel net-snmp-devel openssl-devel opus-devel pcre-devel perl perl-ExtUtils-Embed pkgconfig portaudio-devel postgresql-devel python26-devel python-devel soundtouch-devel speex-devel sqlite-devel unbound-devel unixODBC-devel wget which yasm zlib-devel
yum install libshout libshout-devel -y
yum install lame lame-devel mpg123 mpg123-devel -y

#uploads mysql80-community-release-el7-3.noarch.rpm
rpm -ivh mysql80-community-release-el7-3.noarch.rpm

yum install unixODBC unixODBC-devel libtool-ltdl libtool-ltdl-devel -y
yum install mysql-connector-odbc -y
yum install sems sems-speex -y

#cd /usr/local
#uploads freeswitch-1.6.20.tar.bz2
cd /usr/local
tar jxvf freeswitch-1.6.20.tar.bz2
cd freeswitch-1.6.20/

#uploads modules.conf
#####

./configure
make
make install
```

