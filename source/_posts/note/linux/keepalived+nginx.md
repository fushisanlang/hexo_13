---
title: keepalived + nginx
date: 2017-5-8
updated: 2017-5-9
tags:
  - keepalived
  - nginx
categories:
  - note
abbrlink: fe8bda9b
---



***

### 安装keepalived

```shell
yum install -y openssl-devel
mkdir -p /soft
cd /soft/
wget http://www.keepalived.org/software/keepalived-1.3.5.tar.gz
tar -zvxf keepalived-1.3.5.tar.gz
cd keepalived-1.3.5
./configure --prefix=/usr/local/keepalived
make && make install
cp /soft/keepalived-1.3.5/keepalived/etc/init.d/keepalived /etc/rc.d/init.d/
cp  /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
mkdir /etc/keepalived/
cp /usr/local/keepalived/etc/keepalived/keepalived.conf  /etc/keepalived/
cp /usr/local/keepalived/sbin/keepalived  /usr/sbin/
chmod +x /etc/rc.d/init.d/keepalived
service keepalived start
#service keepalived stop
#service keepalived restart
#service keepalived reload
```



### 配置keepalived

* 主节点

`vim  /etc/keepalived/keepalived.conf`

```
! Configuration File for keepalived
global_defs {
   router_id Keepalived-MASTER
}

vrrp_script chk_nginx {
    script "killall -0 nginx"  #服务探测，返回0说明服务是正常的
    interval 10                 #每隔10秒探测一次
}

vrrp_instance VI_1 {           #实例1
    state MASTER               #指定keepalived的角色，MASTER是主，BACKUP是备用
    interface eth0             #指定HA监测网络的接口
    virtual_router_id 99       #虚拟路由标识，
    priority 100               #定义优先级，数字越大，优先级越高
    nopreempt                  #开启非抢占模式
    mcast_src_ip 192.168.1.180 #发送多播数据包时的源IP地址
    advert_int 1               #设定主与备之间同步检查的时间间隔，单位是秒
    authentication {           #设置验证类型和密码。主从必须一样
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.1.186         #VRRP HA 虚拟地址 如果有多个VIP，继续换行填写
    }
    track_script {             #执行监控的服务
      chk_nginx           #引用VRRP脚本，定期运行它们来改变优先级，引发主备切换。
    }
    notify_master "/etc/keepalived/notify.sh master"  #变为master节点，执行脚本notify.sh
    notify_backup "/etc/keepalived/notify.sh backup"  #变为backup节点，执行脚本notify.sh
    notify_fault "/etc/keepalived/notify.sh fault"    #变为fault节点，执行脚本notify.sh
}
```

* 备节点

`vim  /etc/keepalived/keepalived.conf`
```
! Configuration File for keepalived
global_defs {
   router_id Keepalived-BACKUP
}

vrrp_script chk_nginx {
    script "killall -0 nginx"        #服务探测，返回0说明服务是正常的
    interval 10                 #每隔10秒探测一次
}

vrrp_instance VI_1 {              #实例1
    state BACKUP               #指定keepalived的角色，MASTER是主，BACKUP是备用
    interface eth0               #指定HA监测网络的接口
    virtual_router_id 99          #虚拟路由标识，
    priority 99                  #定义优先级，数字越大，优先级越高
    nopreempt                  #开启非抢占模式
    mcast_src_ip 192.168.1.219    #发送多播数据包时的源IP地址
    advert_int 1                #设定主与备之间同步检查的时间间隔，单位是秒
    authentication {             #设置验证类型和密码。主从必须一样
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.1.186         #VRRP HA 虚拟地址 如果有多个VIP，继续换行填写
    }
    track_script {             #执行监控的服务
      chk_nginx                #引用VRRP脚本，定期运行它们来改变优先级，引发主备切换。
    }
    notify_master "/etc/keepalived/notify.sh master"  #变为master节点，执行脚本notify.sh
    notify_backup "/etc/keepalived/notify.sh backup"  #变为backup节点，执行脚本notify.sh
    notify_fault "/etc/keepalived/notify.sh fault"    #变为fault节点，执行脚本notify.sh
}
```



### 配置日志

```shell
vim /etc/sysconfig/keepalived   #修改
	KEEPALIVED_OPTIONS="-f /etc/keepalived/keepalived.conf  -D -S 0"  

vim  /etc/rsyslog.conf   #增加
	local0.*          /var/log/keepalived/keepalived.log 
	
mkdir /var/log/keepalived 
touch /var/log/keepalived/keepalived.log
service rsyslog  reload
```


### 主备定义主备状态切换通知脚本notify.sh

`vim  /etc/keepalived/notify.sh`

```
#!/bin/bash
case "$1" in                          #判断输入的参数
    master)
        /etc/rc.d/init.d/nginx restart      #若keepalived节点为master，重启nginx
        echo "master" > /tmp/notify   #输出master信息到zabbix监控文件中
        exit 0
    ;;
    backup)
        /etc/rc.d/init.d/nginx restart    #若keepalived节点为backup，重启nginx
        echo "backup" > /tmp/notify  #输出backup信息到zabbix监控文件中
        exit 0
    ;;
    fault)
        /etc/rc.d/init.d/nginx  stop  #若keepalived节点为fault，关闭nginx
        echo "fault" > /tmp/notify   #输出fault信息到zabbix监控文件中
        exit 0
    ;;
    *)                            #若输入为违规情况，输出使用方法
        echo 'Usage: `basename $0` {master|backup|fault}'
echo "unknown" > /tmp/notify  #输出funknown信息到zabbix监控文件中
        exit 1
    ;;
esac
```



### Zabbix中添加keepalived的报警

```shell
vim  /etc/zabbix/zabbix_agentd.d/check_keepalived.conf 
	UserParameter=check_keepalived,sh /usr/local/zabbix/alertscripts/check_keepalived.sh
```

`vim /usr/local/zabbix/alertscripts/check_keepalived.sh`
```shell
#!/bin/bash
result=`ps -C keepalived --no-heading|wc -l`
if [ $result -ne 0 ];then
        echo '1'
else
        echo '0'
fi
```



Zabbix Web界面中添加自定义监控项目，键值为check_keepalived,监控keepalived服务正常返回1，否则返回0；将监控项目获取到的值进行数值映射，0映射为Down;1映射为UP。


定义触发器，最近一次获取的值为0，即服务异常告警



### Keepalived主备服务器的nginx配置文件同步

使用软件：inotify-tools+rsync

同步方式：备节点作为服务端。主节点通过rsync服务将配置文件同步到备节点。

* 备节点配置

```shell
yum install rsync xinetd 
vi /etc/xinetd.d/rsync  
	disable = no #修改,默认为yes
/etc/init.d/xinetd start
```


`vim /etc/rsyncd.conf`

```
#--------------------------------------------------
#globa
#--------------------------------------------------
uid = root
gid = root
port = 873
log file = /var/log/rsyncd.log
pidfile = /var/run/rsyncd.pid
lock file = /var/run/rsyncd.lock
secrets file = /etc/rsyncd.pass
use chroot =yes
max connections = 200
timeout = 200
auth users =bak
#--------------------------------------------------
#client
#--------------------------------------------------
[180-nginx]
path =/usr/local/nginx/conf
comment = "180-nginx"
list =yes
read  only = no
ignore errors = yes
hosts allow = 192.168.1.180
hosts deny = *
```

```shell
vim /etc/rsyncd.pass
	bak:bak
	
chmod  600  /etc/rsyncd.conf  #设置文件所有者读取、写入权限
chmod  600  /etc/rsyncd.pass
service xinetd restart  #重新启动	
```

* 主节点配置

```shell
yum install rsync  
vim /etc/rsyncd.pass
	bak
chmod  600  /etc/rsyncd.pass  
rsync -avz --password-file=/etc/rsyncd.pass /usr/local/nginx/conf/ bak@192.168.1.219::180-nginx #测试
```

* 主节点安装实时监控工具inotify-tools

```shell
yum install inotify-tools -y
cat /usr/bin/notify-rsync
```

```shell
#!/bin/bash
#主服务器端源路径
src=/usr/local/nginx/conf/ 
#备服务器上rsync发布的名称                       
des=180-nginx 
#rsync验证的密码文件                          
rsync_passwd_file=/etc/rsyncd.pass 
#备服务器IP   
ip=192.168.1.219
#rsync定义的同步的用户名                     
user=bak                             
# 此方法中，由于rsync同步的特性，这里必须要先cd到源目录，inotify再监听 ./ 才能rsync同步后目录结构一致
cd ${src}                            
#把监控到有发生更改的"文件路径列表"循环
/usr/bin/inotifywait -mrq --format  '%Xe %w%f' -e modify,create,delete,attrib,close_write,move ./ | while read file        
do      
        #把inotify输出切割-把事件类型部分赋值给INO_EVENT
        INO_EVENT=$(echo $file | awk '{print $1}') 
        #把inotify输出切割-把文件路径部分赋值给INO_FILE     
        INO_FILE=$(echo $file | awk '{print $2}')      
        echo "-------------------------------$(date)------------------------------------"
        echo $file
#增加、修改、写入完成、移动进事件
#增、改放在同一个判断，因为他们都肯定是针对文件的操作，
#即使是新建目录，要同步的也只是一个空目录，不会影响速度。
        #判断事件类型
        if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]] || [[ $INO_EVENT =~ 'CLOSE_WRITE' ]] || [[ $INO_EVENT =~ 'MOVED_TO' ]]         
        then
                echo 'CREATE or MODIFY or CLOSE_WRITE or MOVED_TO'
                #NO_FILE变量代表路径哦  -c校验文件内容,源是用了$(dirname ${INO_FILE})变量 
                #然后用-R参数把源的目录结构递归到目标后面,保证目录结构一致性
                rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip}::${des}       
                 
        fi
        #删除、移动出事件
        if [[ $INO_EVENT =~ 'DELETE' ]] || [[ $INO_EVENT =~ 'MOVED_FROM' ]]
        then
                echo 'DELETE or MOVED_FROM'
                #看rsync命令 如果直接同步已删除的路径${INO_FILE}会报no such or directory错误
                #所以这里同步的源是被删文件或目录的上一级路径，
#并加上--delete来删除目标上有而源中没有的文件
                rsync -avzR --delete --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip}::${des}     
        fi
        #修改属性事件 指 touch chgrp chmod chown等操作
        if [[ $INO_EVENT =~ 'ATTRIB' ]]
        then
                echo 'ATTRIB'
                #如果修改属性的是目录 则不同步，因为同步目录会发生递归扫描，
#此目录下的文件发生同步时，rsync会顺带更新此目录。
                if [ ! -d "$INO_FILE" ]             
                then
                        rsync -avzcR --password-file=${rsync_passwd_file} $(dirname ${INO_FILE}) ${user}@${ip}::${des}            
                fi
        fi
done
```

* 优化inotify
  在/proc/sys/fs/inotify目录下有三个文件，对inotify机制有一定的限制
  * max_user_watches #设置inotifywait或inotifywatch命令可以监视的文件数量(单进程)
  * max_user_instances #设置每个用户可以运行的inotifywait或inotifywatch命令的进程数
  * max_queued_events #设置inotify实例事件(event)队列可容纳的事件数量


```shell
echo 50000000 > /proc/sys/fs/inotify/max_user_watches
echo 50000000 > /proc/sys/fs/inotify/max_queued_events
vim  /etc/rc.d/rc.local #将nginx配置文件实时同步脚本和inotify优化参数加入开机自启
	sh /usr/bin/notify-rsync &
	echo 50000000 > /proc/sys/fs/inotify/max_user_watches
	echo 50000000 > /proc/sys/fs/inotify/max_queued_events
```

* 添加定时任务

```shell
crontab  -e  #因为inotify只在启动时会监控目录，他没有启动期间的文件发生更改，他是不知道的，所以这里每2个小时做1次全量同步，防止各种意外遗漏，保证目录一致。
	* */2 * * *  /usr/bin/rsync -avz --password-file=/etc/rsyncd.pass /usr/local/nginx/conf/  bak@192.168.1.219::180-nginx
```




