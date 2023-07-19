---
title: zabbix_agent安装
date: 2019-10-15
updated: 2019-10-16
categories:
  - note
abbrlink: 5f6adbed
---

## **zabbix-agent安装**


	groupadd zabbix #创建用户组zabbix
	useradd zabbix -g zabbix -s /bin/false #创建用户zabbix，并且把用户zabbix加入到用户组zabbix中
	tar zxf zabbix-3.0.2.tar.gz
	cd zabbix-3.0.2
	./configure --prefix=/usr/local/zabbix --enable-agent #配置
	make #编译
	make install #安装
	
	vi /etc/services #编辑，查找以下代码，如果没有在文件最后添加
		zabbix-agent 10050/tcp # Zabbix Agent
		zabbix-agent 10050/udp # Zabbix Agent
		zabbix-trapper 10051/tcp # Zabbix Trapper
		zabbix-trapper 10051/udp # Zabbix Trapper
		
	vi /usr/local/zabbix/etc/zabbix_agentd.conf #编辑Zabbix配置文件 注意查找以下内容并修改
		Server=192.168.1.231   #192.168.1.231是Zabbix服务端IP地址
		Include=/usr/local/zabbix/etc/zabbix_agentd.conf.d/
		UnsafeUserParameters=1 #启用自定义key
		
	cp misc/init.d/fedora/core/zabbix_agentd /etc/rc.d/init.d/zabbix_agentd  #添加开机启动脚本
	sed -i 's/BASEDIR=\/usr\/local/BASEDIR=\/usr\/local\/zabbix/g' /etc/rc.d/init.d/zabbix_agentd

	chmod +x /etc/rc.d/init.d/zabbix_agentd #添加脚本执行权限
	chkconfig zabbix_agentd on #添加开机启动
	service zabbix_agentd start #启动Zabbix客户端
	ps ax|grep zabbix_agentd #检查Zabbix客户端是否正常运行
	netstat -anlp | grep zabbix_agentd  #检查Zabbix客户端是否正常运行

以下代码在Zabbix服务端执行
	
	/usr/local/zabbix/bin/zabbix_get -s192.168.1.75 -p10050 -k"system.uptime"
	#主要用于验证
	
一切完成后，将“zabbix文件”中的文件按目录放入/var/local/zabbix目录对应位置。

    cd /usr/local/zabbix/scripts
    chomd +x tcp_status.sh

## **zabbix关于percona插件安装**
当需要使用zabbix监控数据库节点时，需要安装此插件以安装对mysql的监控脚本。


    yum install php php-pdo php-mysql php-devel
    rpm -ivh percona-zabbix-templates-1.1.6-1.noarch.rpm 
       # Scripts are installed to /var/lib/zabbix/percona/scripts
       # Templates are installed to /var/lib/zabbix/percona/templates
       # 系统会自动进行上述两项脚本放入操作，所以只需要安装rpm包即可

    vim /var/lib/zabbix/percona/scripts/ss_get_mysql_stats.php
		$mysql_user = 'root';
        $mysql_pass = 'qaz000123';
        $mysql_port = 3306;



需要注意的是，将新的节点加入到监控中时，tcp的监控可能没有数据。

此时，需要将tcp的模板取消关联，更新后再添加关联。然后在agent端重启服务。