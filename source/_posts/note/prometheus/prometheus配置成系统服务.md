---
title: prometheus部署并配置成系统服务
date: 2020-2-21
updated: 2020-2-22
tags:
  - prometheus
  - 监控
categories:
  - note
abbrlink: 4d24aa39
---

# prometheus部署并配置成系统服务

## 部署、启动

可以直接使用Prometheus提供二进制文件：[prometheus download](https://prometheus.io/download/)。

先下载下来，简单试用一下：

```
wget https://github.com/prometheus/prometheus/releases/download/v2.3.2/prometheus-2.3.2.linux-amd64.tar.gz
tar -xvf prometheus-2.3.2.linux-amd64.tar.gz
```

解压以后得到下面的文件：

```
$ ls
console_libraries  consoles  LICENSE  NOTICE  prometheus  prometheus.yml  promtool
```

如果想要学习源代码，可以自己从代码编译：

```
go get github.com/prometheus/prometheus
cd $GOPATH/src/github.com/prometheus/prometheus
git checkout <需要的版本>
make build
```

然后直接运行prometheus程序即可：

```
 ./prometheus
level=info ts=2018-08-18T12:57:33.232435663Z caller=main.go:222 msg="Starting Prometheus" version="(version=2.3.2, branch=HEAD, revision=71af5e29e815795e9dd14742ee7725682fa14b7b)"
level=info ts=2018-08-18T12:57:33.235107465Z caller=main.go:223 build_context="(go=go1.10.3, user=root@5258e0bd9cc1, date=20180712-14:02:52)"
...
```

通过ip:9090，可以打开promtheus的网页。

## 配置系统服务

### centos6

```shell
vim /etc/init.d/prometheus
```

> 下文的脚本中，有三点需要注意：
> 1. 定义脚本必须定义的行是shebang机制，chkconfig和description(4,5系统中必须定义，在6中可以不需要定义)这三行
> 2. chkconfig中2345
chkconfig是一个管理开机启动程序
代表在使用chkconfig –add sshd加入chkconfig列表时候，对应启动模式开机时候是否自动启动，如果设置为-，则表示各个启动级别都不自动启动
> 3. chkconfig中的55和25
系统在启动时候，是有一定的启动顺序的，关机时候也是有顺序的。那么为什么会要求有顺序呢？系统的服务是有依赖的，比如说sshd服务，需要网络服务，如果在网络服务还没有启动起来的时候就启动sshd服务，那肯定会导致sshd服务启动不起来，同样，在关机时候如果先关掉网络服务，sshd将会因为网络的中断而导致未知错误，因此要定义服务启动顺序。
因为服务开机时候，如果进入的是3多用户模式，按照字符顺序执行此/etc/rc.d/rc3.d/中软连接，开机执行的是S(start)开头的软连接，关机执行的是K(kill)的软连接，那么排列在前面的软连接自然要先执行，这样就可以控制服务的启动顺序了。
因此我们在自定义脚本时候，尽量将第一个数写大，第二个数写小，这样在保证所有其他服务开启后，启动我们自定义的脚本，关机时候我们自定义的服务先关掉后再关掉其他服务。有没有觉得设计的很奇妙。
现在回到55和25。在加入chkconfig管理时候，55则代表开机启动时候生成S55sshd的软连接，25代表生成K25sshd的软连接。 [转载出处](https://blog.csdn.net/qq_27754983/java/article/details/74520077)

```shell
#!/bin/bash ###shebang机制
# chkconfig: 2345 11 88
# description: prometheus


######forgo
export PATH=$PATH:/data/prometheus/go/bin
#######

###prometheus
export PROMETHEUS_HOME=/data/prometheus/prometheus/
export PATH=$PATH:${PROMETHEUS_HOME}
#######

start() {
  nohup ${PROMETHEUS_HOME}prometheus --config.file=${PROMETHEUS_HOME}prometheus.yml  >/dev/null  2>&1  &
  PID=`ps -ef | grep '/data/prometheus/prometheus/prometheus'| grep -v grep  |awk '{print $2}'`
  echo "start as pid ${PID}"
}

stop() {
  PID=`ps -ef | grep '/data/prometheus/prometheus/prometheus'| grep -v grep  |awk '{print $2}'`
  echo "find pid ${PID},stoping..."
  kill -9 ${PID}
}

status() {
  PID=`ps -ef | grep '/data/prometheus/prometheus/prometheus'| grep -v grep  |awk '{print $2}'`
  if [[ -n ${PID} ]] ;then
    echo "prometheus run as ${PID}"
  else
    echo "prometheus is stoped"
  fi
}
restart() {
  stop
  start

}

case "$1" in
start)
 start
 ;;

stop)
 stop
 ;;
restart)
 restart
 ;;
status)
 status
 ;;
*)
 echo "Usage: start|stop|restart|status "
 ;;
esac
```
```shell
chmod +x /etc/init.d/prometheus
chkconfig --add prometheus

#完成上诉配置中，即可通过service命令管理进程	
```



### centos7

在centos7中，可以方便的适合用systemd对服务进行托管。具体配置方法如下：

```shell
cd /usr/lib/systemd/system #存储service文件的位置
vi prometheus.service
```

```
[Unit]
Description=prometheus.io

[Service]
ExecStart=/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
```shell
systemctl daemon-reload #生效系统systemd配置文件
systemctl start prometheus #启动服务
```

## 补充说明

以上方法，理论上支持所有其他的服务，比如普罗米修斯的其他组件：node_exporter，alertmanager等。在需要使用systemd或者init对服务进行托管时，可以按照上述的配置方法进行配置，达到托管的目的。

