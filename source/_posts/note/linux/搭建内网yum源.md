---
title: 搭建内网yum源
date: 2019-12-1
updated: 2019-12-2
categories:
  - note
tags:
  - yum
abbrlink: 8831909b
---
## 基于epel源搭建内网yum源




* 背景说明

基于安全性考虑，生产环境的服务器是没有外网访问权限，所以无法使用外网的yum源。

基于性能考虑，外网的源连接速度远远小于内网环境。

基于软件的版本控制考虑，同一套环境内的软件应该尽量保持一致。

所以打算在公司生产网络内，自建一个内网yum源。

* 硬件准备

|  名称  |    配置     |
| :--: | :-------: |
|  内存  |    2G     |
| cpu  |    2C     |
|  硬盘  | 40G   lvm |

* 基于epel源获取安装包


```shell
#创建用于存放软件包的目录
mkdir -p /yum_data/epel/6/x86_64/
mkdir -p /yum_data/centos/6/os/x86_64/ 
mkdir -p /yum_data/centos/6/updates/x86_64/

#同步epel源中的软件包，本文档使用的是ustc的epel源
rsync -av rsync://mirrors.ustc.edu.cn/epel/6/x86_64/ /yum_data/epel/6/x86_64/
rsync -av rsync://mirrors.ustc.edu.cn/centos/6/os/x86_64/ /yum_data/centos/6/os/x86_64/ 
rsync -av rsync://mirrors.ustc.edu.cn/centos/6/updates/x86_64/ /yum_data/centos/6/updates/x86_64/
#上述同步过程中，可能会有无法连接或者连接数超限之类的报错，多试几次即可
```

* 创建repodata索引文件

```shell
#安装相关软件
yum -y install createrepo
#创建索引文件
createrepo -pdo /yum_data /yum_data
```

* 配置nginx

```shell
#网络的yum源需要一个web服务器进行发布。因目前我司大部分使用的事nginx，所以本文以nginx为例
cd ${nginx_dir}/conf/${vhost_dir}
vim ${confname}.conf

	server {
		listen       80;
        server_name  1.2.3.4 ; #此处可以配置ip或者域名。推荐使用内网IP，本处已1.2.3.4做示例

		location /yum_data {
			root /;
			autoindex_exact_size off;
			autoindex_localtime on;
			autoindex on;
		}
	}
service nginx reload

#测试
curl 1.2.3.4 -I #如果返回值是200即可，如果不是200则需要通过nginx的日志查找原因。
```

* 在其他服务器上配置内网yum源

```shell
cd /etc/yum.repos.d
mkdir -p bak
mv * bak
vim yum.repo #注意修改IP

	[base]
	name=Self-built base source base on ustc
	baseurl=http://1.2.3.4/yum_data/centos/$releasever/os/$basearch/
	gpgcheck=0

	[updates]
	name=Self-built updates source base on ustc
	baseurl=http://1.2.3.4/yum_data/centos/$releasever/updates/$basearch/
	gpgcheck=0

	[epel]
	name=Self-built epel source base on ustc
	baseurl=http://1.2.3.4/yum_data/epel/6/$basearch
	enabled=1
	gpgcheck=0
	
yum clean all #清除yum缓存
yum repolist  #查看源中的包个数。
```

