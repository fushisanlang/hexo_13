---
title: squid+ad认证+keepalived
date: 2016-10-7
updated: 2016-10-8
tags:
  - squid
  - keepalived
  - ad认证
  - ldap
categories:
  - note
abbrlink: 1f5fbe3f
---

## 1 环境说明

### 1.1 软件版本

|     soft      |               version                |
| :-----------: | :----------------------------------: |
|      os       | CentOS Linux release 7.7.1908 (Core) |
|     squid     |                4.1-5                 |
| squid-helpers |                4.1-5                 |
|   openldap    |              2.4.44-21               |
|  keepalived   |               1.3.5-19               |

### 1.2 ip说明

|       ip       |  用途  |
| :------------: | :----: |
| 192.168.92.140 | master |
| 192.168.92.141 | slave  |
| 192.168.92.150 |  vip   |

## 2 安装配置squid

### 2.1 安装
```shell
vim /etc/yum/squid.repo

[squid]
name=Squid repo for CentOS Linux - 7
#IL mirror
baseurl=http://www1.ngtech.co.il/repo/centos/$releasever/beta/$basearch/
failovermethod=priority
enabled=1
gpgcheck=0

yum install -y squid squid-helpers
```

### 2.2 配置
```shell
cat squid_confd.conf > /etc/squid/squid.conf #squid_confd.conf 见附1
mkdir /data/squid_files -p
ln -s /data/squid_files /etc/squid/squid_files
touch /etc/squid/squid_files/deny-net #网站黑名单列表
squid -z #创建缓存
systemctl start squid
```
<!--more-->


## 3 squid相关配置说明

### 3.1 简单http验证
```shell
#这种认证方式是通过htpasswd命令，生成一个数据库文件，squid通过数据库文件对用户进行校验
htpasswd -cb user.pass fushisanlang zzz #-c代表生成一个文件 -b是通过命令行提交密码 
htpasswd -b user.pass fushisanlang zzz #如果已经有相应密码文件，就不用-c参数了

vim /etc/squid/squid.conf

auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/squid_files/user.pass    #定义squid密码文件，记录所有用户与密码
auth_param basic children 15          #认证进程的数量
auth_param basic credentialsttl 24 hours        #认证有效期
auth_param basic casesensitive off             #用户名不区分大小写，可改为ON区分大小写

#通过上述配置可以启用squid的简单认证
```

### 3.2 结合windows的ad验证
```shell
# 因为公司使用windows域进行用户控制，所以研究了一下ldap的认证方式

vim /etc/squid/squid.conf

auth_param basic program /usr/lib64/squid/basic_ldap_auth -R -b "dc=fushisanlang,dc=cn" -D "fushisanlang@fushisanlang.cn" -w "xxx" -f sAMAccountName=%s -h 10.110.1.138
#这里是通过basic_ldap_auth来进行验证，如果是通过编译安装的squid，需要在编译的时候添加--enable-basic-auth=LDAP参数，并且安装openldap-devel依赖，如果是yum安装，则直接安装squid-helpers包即可。
#启动-b是基础域信息，-D里边是查询时需要用到的用户信息。-w是用户密码。-f是查询的数据，是一个过滤器。-h指定的是ladp服务的地址。
auth_param basic children 5
auth_param basic realm Web-Proxy
auth_param basic credentialsttl 1 minute
acl ldap-auth proxy_auth REQUIRED #这里是一个配置，用来把所有通过ladp认证的用户定义为一个组，组名叫ldap-auth，方便后续做策略划分

# 在配置时，可能会遇见无法认证的情况。可以通过ldapsearch命令进行验证，如果返回了信息，说明ladp服务连接成功，以下是示例
ldapsearch -x -w Yierer333 -D "fushisanlang@fushisanlang.cn" -b "dc=fushisanlang,dc=cn" -h 10.110.1.138
```

### 3.3 acl策略划分

```shell
vim /etc/squid/squid.conf

acl leader proxy_auth "/etc/squid/squid_files/leader" #通过文件定义用户组
acl intranet dstdom_regex "/etc/squid/squid_files/intranet"  #通过文件定义url组
#acl支持多种定义模式

http_access allow intranet
http_access deny intranet leader
#通过allow和deny来控制允许还是拒绝，多个参数是与的关系。多条策略从第一条开始匹配，命中后不匹配
```

### 3.4 限速配置

```shell
delay_pools 1 #开启连接延迟池

delay_class 1 1 #定义延迟池，class类型为1,这个类型有2 3 ，代表整个B类，C类网段，但是网上没有示例，这里直接采用1

delay_parameters 1 2048000/2048000 #20480000 B #这里是指，通过上边定义的延迟池1 进行限速。总带宽是2048000，单个ip带宽是2048000。 这里的单位是B

delay_access 1 allow ldap-auth #这个是指，限制整个ldap-auth组的用户，即所有通过ladp认证的用户都遵循此规则

delay_initial_bucket_level 100 #这里是指，初始化的百分比，抄来的，没仔细研究。
```

### 3.5 更多配置

[squid 配置示例](https://wiki.squid-cache.org/ConfigExamples) 是官网给出的配置示例，可以用于参考

## 4 安装配置keepalived

```shell
yum install -y keepalived
cat keepalived.conf.master > /etc/keepalived/keepalived.conf #master操作，文件见附2
cat keepalived.conf.slave > /etc/keepalived/keepalived.conf #slave操作，文件见附3
cat chk_squid.sh > /data/squid_files/chk_squid.sh #文件见附4

systemctl start keepalived
```

## 5 后续配置

### 5.1 文件同步

```shell
vim /data/squid_files/notify_conf.go
```

```go
package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/fsnotify/fsnotify"
)

type Watch struct {
	watch *fsnotify.Watcher
}

func scpFile(filename string) {

	cmd := exec.Command("bash", "-c", "scp -pr "+filename+" root@fushisanlang.cn:/data/squid_files")

	cmd.Run()
	return
}

func (w *Watch) watchDir(dir string) {
	filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if info.IsDir() {
			path, err := filepath.Abs(path)

			if err != nil {
				return err
			}
			err = w.watch.Add(path)
			if err != nil {
				return err
			}

		}
		return nil
	})
	go func() {
		for {
			select {
			case ev := <-w.watch.Events:
				{

					if ev.Op&fsnotify.Create == fsnotify.Create {

						scpFile(ev.Name)
						fi, err := os.Stat(ev.Name)
						if err == nil && fi.IsDir() {
							w.watch.Add(ev.Name)

						}
					}
					if ev.Op&fsnotify.Write == fsnotify.Write {

						scpFile(ev.Name)
					}
					if ev.Op&fsnotify.Remove == fsnotify.Remove {

						fi, err := os.Stat(ev.Name)
						if err == nil && fi.IsDir() {
							w.watch.Remove(ev.Name)

						}
					}
					if ev.Op&fsnotify.Rename == fsnotify.Rename {

						w.watch.Remove(ev.Name)
						scpFile(ev.Name)
					}

				}

			}
		}
	}()
}

var (
	dirs   [0]string
	dirs_s []string = dirs[:]
)

func main() {

	watch, _ := fsnotify.NewWatcher()
	w := Watch{
		watch: watch}
	dir := "/data/squid_files"
	w.watchDir(dir)

	select {}
}

```

```shell
go build /data/squid_files/notify_conf.go
nohup /data/squid_files/notify_conf & 
```

### 5.2 日志切割

```shell
#因为是yum安装，日志在/var/log/squid中已经完成了切割，只需要添加一个压缩即可。
#这个步骤可通系统自带的日志工具操作，也可以自己写脚本操作。我这里为了以后和其他的功能集成，使用了脚本的方式
vim /data/squid_files/gz_log.sh
    #!/bin/bash
    #for gz squid log every day
    #by zhangyin

    workdir="/var/log/squid/"

    cd ${workdir}
    ls * | egrep -v 'log$|out$|gz$' | while read logfile
    do
        gzip $logfile
    done

crontab -e
 0 8 * * * /bin/bash /data/squid_files/gz_log.sh
```

## 6 配置示例

### 6.1 linux

```
export http_proxy=http://{user}:{pass}@10.110.1.188:3128
export https_proxy=http://{user}:{pass}@10.110.1.188:3128 
export ftp_proxy=http://{user}:{pass}@10.110.1.188:3128
```

### 6.2 windows

```
#在环境变量中添加如下变量后，可以在cmd中生效。

HTTP_proxy=http://{user}:{pass}@10.110.1.188:3128
HTTPS_proxy=http://{user}:{pass}@10.110.1.188:3128 
FTP_proxy=http://{user}:{pass}@10.110.1.188:3128


#在浏览器中配置相关代理，即可在浏览器中生效

```

## 附件

### 附件1：squid_confd.conf

```
acl SSL_ports port 443
acl Safe_ports port 80      # http
acl Safe_ports port 21      # ftp
acl Safe_ports port 22      # ssh
acl Safe_ports port 443     # https
acl Safe_ports port 1025-65535      # 自定义端口
acl CONNECT method CONNECT
http_access deny !Safe_ports
#http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
http_access allow localhost
http_port 3128
coredump_dir /var/spool/squid
#refresh_pattern ^ftp:       1440    20% 10080
#refresh_pattern ^gopher:    1440    0%  1440
#refresh_pattern -i (/cgi-bin/|\?) 0 0%  0
#refresh_pattern .       0   20% 4320
ident_lookup_access deny all

cache_mem 0 MB                       #正向代理不需要缓存
maximum_object_size_in_memory 8 MB
memory_replacement_policy heap LFUDA        #动态使用最小的，移出内存cache
cache_replacement_policy heap LFUDA         #动态使用最小的，移出硬盘cache
cache_dir ufs /data/squid_files/cache 5000 32 512       #高速缓存目录 ufs 类型
refresh_pattern . 0 20% 4320 override-expire override-lastmod reload-into-ims ignore-reload   #更新cache规则

cache_effective_user squid                  #这里以用户squid的身份Squid服务器
cache_effective_group squid
icp_port 0                       #指定Squid从邻居服务器缓冲内发送和接收ICP请求的端口号。
                                 #这里设置为0是因为这里配置Squid为内部Web服务器的加速器，
                                 #所以不需要使用邻居服务器的缓冲。0是禁用
always_direct allow all 
ignore_unknown_nameservers on

##账号设置
#auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/squid_files/user.pass    #定义squid密码文件，记录所有用户与密码
#auth_param basic children 15          #认证进程的数量
#auth_param basic credentialsttl 24 hours        #认证有效期
#auth_param basic casesensitive off             #用户名不区分大小写，可改为ON区分大小写
#
##用户及黑白名单设置
#acl leader proxy_auth "/etc/squid/squid_files/leader"  #设置领导
#acl staff proxy_auth "/etc/squid/squid_files/staff" #设置员工
#acl special-staff proxy_auth "/etc/squid/squid_files/special-staff" #设置特殊员工
#
##acl intranet dstdom_regex "/etc/squid/squid_files/intranet"  #设置内网
##acl extranet dstdom_regex "/etc/squid/squid_files/extranet"  # 设置外网
#acl special-extranet dstdom_regex "/etc/squid/squid_files/special-extranet"  # 设置特殊外网
#acl deny-net dstdom_regex "/etc/squid/squid_files/deny-net"  #设置黑名单
#
#
##http_access allow intranet #允许所有人访问内网
##http_access allow extranet #允许所有人访问内网
##http_access allow special-staff special-extranet #允许特殊员工访问特殊外网
##http_access deny deny-net #禁止所有人访问黑名单
##http_access allow all #允许访问所有非黑名单地址
##http_access allow leader all #允许领导访问所有网址
#http_access allow leader #允许领导访问所有网址
#http_access deny staff deny-net #禁止普通员工访问黑名单
#http_access allow special-staff special-extranet #允许特殊员工访问特殊外网
#http_access deny special-staff deny-net #禁止特殊员工访问黑名单
#http_access allow all #允许访问所有非黑名单地址
#
##ftp设置
#acl FTP proto FTP
#always_direct allow FTP
auth_param basic program /usr/lib64/squid/basic_ldap_auth -R -b "dc=ncimall,dc=cn" -D "superman@ncimall.cn" -w "DC@adm1n" -f sAMAccountName=%s -h 10.110.1.138 
auth_param basic children 15
auth_param basic realm Web-Proxy
auth_param basic credentialsttl 24 hours
acl ldap-auth proxy_auth REQUIRED

delay_pools 1 #开启连接延迟池

delay_class 1 1 #定义延迟池，class类型为1

delay_parameters 1 2048000/2048000 #20480000 B

delay_access 1 allow ldap-auth

delay_initial_bucket_level 100

acl deny-net dstdom_regex "/etc/squid/squid_files/deny-net"  #设置黑名单
http_access deny deny-net #禁止访问黑名单
http_access allow ldap-auth
http_access deny all


```

### 附件2：keepalived.conf.master

```
! Configuration File for keepalived

global_defs {
    router_id MASTER-HA
}

vrrp_script chk_squid_port {
    script "/data/squid_files/chk_squid.sh"
    interval 2
    weight -5
    fall 2
    rise 1
}

vrrp_instance VI_1 {
    state MASTER
    interface ens33
    mcast_src_ip 192.168.92.140
    virtual_router_id 151
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.92.150
    }

    track_script {
        chk_squid_port
    }
}

```

### 附件3：keepalived.conf.slave

```
! Configuration File for keepalived

global_defs {
    router_id MASTER-HA
}

vrrp_script chk_squid_port {
    script "/data/squid_files/chk_squid.sh"
    interval 2
    weight -5
    fall 2
    rise 1
}

vrrp_instance VI_1 {
    state BACKUP
    interface ens33
    mcast_src_ip 192.168.92.141
    virtual_router_id 151
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
         192.168.92.151
    }

    track_script {
        chk_squid_port
    }
}

```

### 附件4：chk_squid.sh

```
#!/bin/bash
counter=$(netstat -na|grep "LISTEN"|grep "3128"|wc -l)
if [ "${counter}" -eq 0 ]; then
  systemctl stop keepalived
fi

```