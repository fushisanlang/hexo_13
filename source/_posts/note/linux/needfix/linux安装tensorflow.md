---
title: linux安装tensorflow
date: 2016-7-2
updated: 2016-7-3
categories:
  - note
abbrlink: 8e6f7392
---
# linux 安装 tensorflow

### 一、安装python3

*[软件源](https://www.python.org/ftp/python)*

1. 下载软件
```shell
mkdir -p /soft 
cd /soft 
wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tgz
```
2. 安装
```shell
tar xf Python-3.6.6.tgz
cd Python-3.6.6
mkdir -p /usr/local/python3
./configure --prefix=/usr/local/python3
make && make install
```
3. 配置环境变量
```shell
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
vim ~/.bash_profile
	PATH=$PATH:$HOME/bin:/usr/local/python3/bin
source ~/.bash_profile
```

### 二、安装GLIBC2.16

*[软件源](http://ftp.gnu.org/pub/gnu/glibc/)*

1. 下载软件

``` shell
mkdir -p /soft 
cd /soft 
wget http://ftp.gnu.org/pub/gnu/glibc/glibc-2.16.0.tar.gz
```
2. 安装
```shell
tar xf glibc-2.16.0.tar.gz
cd glibc-2.16.0
mkdir -p build && cd build
../configure --prefix=/opt/glibc-2.14 
make && make install
```
3. 配置环境变量
```shell
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
vim ~/.bash_profile
	PATH=$PATH:$HOME/bin:/usr/local/python3/bin
source ~/.bash_profile
```
