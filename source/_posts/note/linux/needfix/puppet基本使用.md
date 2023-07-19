---
title: puppet基本使用
date: 2019-10-11
updated: 2019-10-12
categories:
  - note
abbrlink: 667b045a
---
# puppet基本使用

***
### 环境准备

server1 172.25.34.1
server2 172.25.34.2
server3 172.25.34.3

因为需要通过ssl连接，所以**需要三者之间时间相同，互相有解析。**




### 安装

* server1
```shell
yum install -y puppet-server-3.8.1-1.el6.noarch.rpm puppet-3.8.1-1.el6.noarch.rpm facter-2.4.4-1.el6.x86_64.rpm hiera-1.3.4-1.el6.noarch.rpm rubygem-json-1.5.5-3.el6.x86_64.rpm ruby-shadow-2.2.0-2.el6.x86_64.rpm ruby-augeas-0.4.1-3.el6.x86_64.rpm rubygems-1.3.7-5.el6.noarch.rpm 
```


server2，3
```shell
yum install -y puppet-3.8.1-1.el6.noarch.rpm facter-2.4.4-1.el6.x86_64.rpm hiera-1.3.4-1.el6.noarch.rpm rubygem-json-1.5.5-3.el6.x86_64.rpm ruby-shadow-2.2.0-2.el6.x86_64.rpm ruby-augeas-0.4.1-3.el6.x86_64.rpm rubygems-1.3.7-5.el6.noarch.rpm
```



### 认证

agents需要从master获得认证，有两种方式，手动认证和自动认证。

#### 手动认证

* server1

通过   `puppet cert list --all`   命令查看已经认证的agent。
通过   `puppet cert list`               命令查看等待认证的agent。

* server 2,3

通过  `puppet agent --server server1.example.com --no-daemonize -vt`  命令向master发送认证请求。

* server1

通过  `puppet cert sign server2.example.com`  命令通过请求。

* server2，3

再次通过  `puppet agent --server server1.example.com --no-daemonize -vt`  命令即可完成认证。

####  自动认证

* server1

```shell
cd /etc/puppet
vim puppet.conf
	autosign = ture
	/etc/init.d/puppetmaster reload
```

* server2,3
```shell
puppet agent --server server1.example.com --no-daemonize -vt
```

#### 删除认证

* server1

```shell
puppet cert --clean desktop2.example.com
```

* server2,3
```shell
rm -fr /var/lib/puppet/ssl/*    #该目录中存放的就是认证的文件，为了方便下次认证，应该将该目录下的文件清空。
```



### 基本使用


####  分节点

因为不能确保每个节点的要求相同，所以可以通过分节点的方式定义.pp文件。

```shell
cd /etc/puppet/manifests
mkdir nodes
echo "import 'nodes/*.pp'" > site.pp
cd nodes
vim default.pp
	node default {
	}

vim server2.pp
	node 'server2.example.com' {
		file{
			"/var/www/html/index.html":
			content => "hello server2.example.com"
		}
	}

vim server3.pp
	node 'server3.example.com' {
	}
```

####  分块使用

```shell
mkdir -p /etc/puppet/modules/httpd/manifests
vim init.pp
	class httpd{
		include httpd::install, httpd::config, httpd::service
	}

vim install.pp
	class httpd::install {
		package {
			"httpd":
			ensure => present	
		}
	}

vim config.pp
	class httpd::config {
		file {
			"/etc/httpd/conf/httpd.conf":
			source => "puppet:///modules/httpd/httpd.conf",
			require => Package["httpd"],
			notify => Service["httpd"]
		}
	}

vim service.pp
	class httpd::service {
		service {
			"httpd":
			ensure => running
		}
	}

cd /etc/puppet/manifests/nodes
vim server3.pp
	node 'server3.example.com' {
		include httpd
	}
```