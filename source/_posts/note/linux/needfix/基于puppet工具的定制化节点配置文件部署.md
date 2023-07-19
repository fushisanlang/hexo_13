---
title: 基于puppet 工具的定制化节点配置文件部署
date: 2018-2-20
updated: 2018-2-21
categories:
  - note
tags:
  - puppet
abbrlink: 7c5f96c6
---
# 基于puppet 工具的定制化节点配置文件部署



### 1. 背景说明

> 目前我司的多节点平台，比如扫码、缴费平台。因为功能性不同，所以平台内各节点的相应配置文件也存在差异。   
> 生产上线过程中，当有相关配置文件变动时，就需要运维人员手工对各个节点进行手工修改。不仅浪费时间，也容易因为人为原因造成配置文件修改错误，导致生产异常。   
> 因此，急切需要一个能够差异化部署配置文件的自动化工具。   
> 经过调研，发现puppet工具对此应用场景很适用。   
>

*目前我司正在使用的ansible工具，同样可以完成类似的配置。只不过配置方式相比于puppet来说比较复杂一些。*

### 2. 工作原理简介

简化来说，每次配置有如下四个环节：

1. 首先所有的Node节点将Facts和本机信息发送给Master。
2. Master告诉Node节点应该如何配置，将这些信息写入Catalog后传给Node。
3. Node节点在本机进行代码解析验证并执行，将结果反馈给Master。
4. Master通过API将数据发给分析工具。报告完全可以通过开放API或与其他系统集成。

[相关文档](http://blog.51cto.com/blief/1760439)

### 3. 测试环境介绍

> 本方案理论上使用于我司所有多节点平台。但是并未经过实际验证。   
> 在验证试验中，使用扫码平台的相关配置文件进行测试。   
> 理论上，puppet更适用于拥有内部DNS的集群，但是由于我司目前并无相应工具，所以后期一些解析内容就要在hosts文件中进行配置。   
> 另外，此工具使用时需要所有的节点之间应该有ntp同步。


|  节点功能  |      节点ip       |                相关备注                |
| :----: | :-------------: | :--------------------------------: |
| master | 192.168.122.100 |    作为服务端管理节点，关闭iptables和selinux    |
| agent1 | 192.168.122.101 | 作为无特殊配置需求的普通客户端，关闭iptables和selinux |
| agent2 | 192.168.122.102 | 作为有特殊配置需求的特殊客户端，关闭iptables和selinux |

### 4. 环境搭建

* master

```shell
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm  #安装epel源
rpm -ivh http://yum.puppetlabs.com/el/6x/products/x86_64/puppetlabs-release-6-7.noarch.rpm  #安装puppet源
yum install -y puppet-server puppet facter hiera rubygem-json ruby-shadow ruby-augeas rubygems tree #安装相关软件

chkconfig puppetmaster on

vim /etc/sysconfig/network  #修改master主机名
	NETWORKING=yes
	HOSTNAME=master.ronglian.puppet
	
vim /etc/hosts  #添加master主机hosts解析
	192.168.122.100	master.ronglian.puppet
	
init 6 #重启服务器，修改主机名需要重启才能生效
```

* agent1、agent2


```shell
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm  #安装epel源
rpm -ivh http://yum.puppetlabs.com/el/6x/products/x86_64/puppetlabs-release-6-7.noarch.rpm  #安装puppet源
yum install -y  puppet facter hiera rubygem-json ruby-shadow ruby-augeas rubygems tree #安装相关软件

vim /etc/hosts  #添加master主机hosts解析
	192.168.122.100	master.ronglian.puppet
```



### 5. 客户端认证

因为puppet工具的节点间通讯，是基于ssl加密协议的。所以所有agent端都需要向master端进行认证。

agent需要从master获得认证，有两种方式：手动认证和自动认证。



1.	 自动认证

此种方式，适用于拥有DNS的集群，与我司状况不符，故不赘述。



2.	  手动认证

* master

通过   `puppet cert list --all`   命令查看已经认证的agent。
通过   `puppet cert list`               命令查看等待认证的agent。

* agent 1

通过   `puppet agent --server master.ronglian.puppet --no-daemonize -vt --certname 192.168.122.101 `  命令向master发送认证请求。 

* master

通过  `puppet cert sign 192.168.122.101`  命令通过请求。

* agent 1

再次通过   `puppet agent --server master.ronglian.puppet --no-daemonize -vt --certname 192.168.122.101 `  命令进行验证，若无报错则代表认证成功。

agent2认证方式与agent1相同，但是需要认证时将证书名（certname）换成自己的IP即可。



3.	删除认证

* master

```shell
puppet cert --clean $certname
```

* agent
```shell
rm -fr /var/lib/puppet/ssl/*    #该目录中存放的就是认证的文件，为了方便下次认证，应该将该目录下的文件清空。
```


### 6. 测试使用

1.	首先，在agent1 、2上分别创建相应目录及配置文件，为等下的配置文件同步做准备。

agent 1、2
```shell
mkdir /home/ap
useradd -d /home/ap/tomcat -u 504 tomcat
su - tomcat
$ mkdir -p jfpt_qd{,_2,_3,_4}/webapps/jfpt_qd/WEB-INF/classes
```

agent 1

```shell
$ echo common > jfpt_qd/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml
$ echo common > jfpt_qd_2/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml
$ echo common > jfpt_qd_3/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml
$ echo common > jfpt_qd_4/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml
```

agent 2

```shell
$ echo special1 > jfpt_qd/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml
$ echo special2 > jfpt_qd_2/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml
$ echo special3 > jfpt_qd_3/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml
$ echo special4 > jfpt_qd_4/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml
```

agent 1、2

```shell
$ tree ~

    /home/ap/tomcat
    ├── jfpt_qd
    │   └── webapps
    │       └── jfpt_qd
    │           └── WEB-INF
    │               └── classes
    │                   └── applicationContext.xml
    ├── jfpt_qd_2
    │   └── webapps
    │       └── jfpt_qd
    │           └── WEB-INF
    │               └── classes
    │                   └── applicationContext.xml
    ├── jfpt_qd_3
    │   └── webapps
    │       └── jfpt_qd
    │           └── WEB-INF
    │               └── classes
    │                   └── applicationContext.xml
    └── jfpt_qd_4
        └── webapps
            └── jfpt_qd
                └── WEB-INF
                    └── classes
                        └── applicationContext.xml
    
    20 directories, 4 files 

```

2.	配置master

```shell
echo "path /etc/puppet" >> /etc/puppet/auth.conf
vim /etc/puppet/fileserver.conf
	[files]
	path /etc/puppet/files
	allow *

cd /etc/puppet/manifests
echo "import 'nodes/*.pp'" >  site.pp
mkdir nodes

vim default.pp
	node default {
	}

vim jfpt_qd.pp

    node '192.168.122.101' {
        file{
            "/home/ap/tomcat/jfpt_qd/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml":
            source => "puppet:///files/common",
        }
        file{
            "/home/ap/tomcat/jfpt_qd_2/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml":
            source => "puppet:///files/common",
        }
        file{
            "/home/ap/tomcat/jfpt_qd_3/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml":
            source => "puppet:///files/common",
        }
        file{
            "/home/ap/tomcat/jfpt_qd_4/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml":
            source => "puppet:///files/common",
        }
    }
    node '192.168.122.102' {
        file{
            "/home/ap/tomcat/jfpt_qd/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml":
            source => "puppet:///files/special1",
        }
        file{
            "/home/ap/tomcat/jfpt_qd_2/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml":
            source => "puppet:///files/special2",
        }
        file{
            "/home/ap/tomcat/jfpt_qd_3/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml":
            source => "puppet:///files/special3",
        }
        file{
            "/home/ap/tomcat/jfpt_qd_4/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml":
            source => "puppet:///files/special4",
        }
    }
    
echo "new common"   >  /etc/puppet/files/common   
echo "new special1" >  /etc/puppet/files/special1
echo "new special2" >  /etc/puppet/files/special2
echo "new special3" >  /etc/puppet/files/special3
echo "new special4" >  /etc/puppet/files/special4

/etc/init.d/puppetmaster reload
```



3. 同步测试

agent 1

```shell
$ puppet agent --server master.ronglian.puppet --no-daemonize -vt --certname 192.168.122.101
$ cat ~/jfpt_qd{,_2,_3,_4}/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml
	new common
	new common
	new common
	new common
```

agent 2
```shell
$ puppet agent --server master.ronglian.puppet --no-daemonize -vt --certname 192.168.122.102
$ cat ~/jfpt_qd{,_2,_3,_4}/webapps/jfpt_qd/WEB-INF/classes/applicationContext.xml
	new special1
	new special2
	new special3
	new special4
```

至此实验成功。

### 7. F&Q

> Q：同步后文件的用户和权限怎么保证？
>
> A：经过试验，文件的用户是根据agent上执行同步命令的用户确认的。文件的属性是根据master上文件的属性延续的。所以在使用过程中，要注意相应的用户和权限。

> Q：同步的命令如何执行？需要每次都登录到agents上执行么？
>
> A：一般的使用场景是定时的去和master同步，所以需要配置puppet agent端的一些参数，达到自动的效果。 但是由于我司使用场景的不同，不建议此种方式。
> 由于我司更改配置文件多数情况都是在生产上线时，所以建议可以通过ansible自动更新脚本，连带执行agent的同步命令。既可以保证配置文件更新的实时性，又能保证生产上线时过多人为操作带来的不稳定性。

> Q：如果不小心删除或修改了master端存放的配置文件，在agent端会有什么影响？
>
> A：如果是删除，agent端在同步的时候会报错，不会继续同步，从而保留原有的文件不变。
> 如果是修改，并且agent端进行了同步，那么就会将修改后的文件同步到agent端，会造成很大的影响。所以建议master端的控制权应该保留在少数实施人员手中。

> Q：此工具与ansible工具的使用场景分别是什么？会替代ansible么？
>
> A：目前规划的使用场景为，ansible依然用于批量的自动化更新任务，puppet则用于更新中需要差异化更新的某个或某些文件。