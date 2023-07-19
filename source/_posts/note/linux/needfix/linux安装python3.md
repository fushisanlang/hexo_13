---
title: linux安装python3
date: 2019-1-3
updated: 2019-1-4
categories:
  - note
abbrlink: 82eef90b
---
# linux 安装 python3

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


