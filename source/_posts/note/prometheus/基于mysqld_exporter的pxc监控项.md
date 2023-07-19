---
title: 基于mysqld_exporter的pxc监控项
date: 2019-10-4
updated: 2019-10-5
tags:
  - prometheus
  - 监控
  - mysql
  - pxc
categories:
  - note
abbrlink: 60b0e8c6
---


# 基于mysqld_exporter的pxc监控项

[pxc建议的监控项](https://www.percona.com/doc/percona-xtradb-cluster/LATEST/manual/monitoring.html)


* ### 集群完整性检查:

	* wsrep_cluster_status:集群组成的状态.如果不为”Primary”,说明出现”分区”或是”split-brain”状况.
	> HELP mysql_global_status_wsrep_cluster_status Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_cluster_status untyped
	`mysql_global_status_wsrep_cluster_status 1`
	
	* wsrep_cluster_size:如果这个值跟预期的节点数一致,则所有的集群节点已经连接.
	> HELP mysql_global_status_wsrep_cluster_size Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_cluster_size untyped
	`mysql_global_status_wsrep_cluster_size 3`




* ### 节点状态检查:

	* wsrep_ready: 该值为ON,则说明可以接受SQL负载.如果为Off,则需要检查wsrep_connected.
	> HELP mysql_global_status_wsrep_ready Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_ready untyped
	`mysql_global_status_wsrep_ready 1`
	
	* wsrep_connected: 如果该值为Off,且wsrep_ready的值也为Off,则说明该节点没有连接到集群.(可能是wsrep_cluster_address或wsrep_cluster_name等配置错造成的.具体错误需要查看错误日志)
	> HELP mysql_global_status_wsrep_connected Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_connected untyped
	`mysql_global_status_wsrep_connected 1`
	
	


* ### 复制健康检查:

	* wsrep_flow_control_paused:表示复制停止了多长时间.即表明集群因为Slave延迟而慢的程度.值为0~1,越靠近0越好,值为1表示复制完全停止.可优化wsrep_slave_threads的值来改善.
	> HELP mysql_global_status_wsrep_flow_control_paused Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_flow_control_paused untyped
	`mysql_global_status_wsrep_flow_control_paused 0`
	
	* wsrep_cert_deps_distance:有多少事务可以并行应用处理.wsrep_slave_threads设置的值不应该高出该值太多.
	> HELP mysql_global_status_wsrep_cert_deps_distance Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_cert_deps_distance untyped
	`mysql_global_status_wsrep_cert_deps_distance 0`
	
	* wsrep_flow_control_sent:表示该节点已经停止复制了多少次.
	> HELP mysql_global_status_wsrep_flow_control_sent Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_flow_control_sent untyped
	`mysql_global_status_wsrep_flow_control_sent 0`
	
	* wsrep_local_recv_queue_avg:表示slave事务队列的平均长度.slave瓶颈的预兆.
	> HELP mysql_global_status_wsrep_local_recv_queue_avg Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_local_recv_queue_avg untyped
	`mysql_global_status_wsrep_local_recv_queue_avg 0.125`
	
	> 最慢的节点的wsrep_flow_control_sent和wsrep_local_recv_queue_avg这两个值最高.这两个值较低的话,相对更好.
	
	


* ### 检测慢网络问题:

	* wsrep_local_send_queue_avg:网络瓶颈的预兆.如果这个值比较高的话,可能存在网络瓶颈
	> HELP mysql_global_status_wsrep_local_send_queue_avg Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_local_send_queue_avg untyped
	`mysql_global_status_wsrep_local_send_queue_avg 0`
	
	
	* wsrep_last_committed:最后提交的事务数目
	> HELP mysql_global_status_wsrep_last_committed Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_last_committed untyped
	`mysql_global_status_wsrep_last_committed 20`
	
	* wsrep_local_cert_failures和wsrep_local_bf_aborts:回滚,检测到的冲突数目
	> HELP mysql_global_status_wsrep_local_bf_aborts Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_local_bf_aborts untyped
	`mysql_global_status_wsrep_local_bf_aborts 0`
	
	> HELP mysql_global_status_wsrep_local_cert_failures Generic metric from SHOW GLOBAL STATUS.
	> TYPE mysql_global_status_wsrep_local_cert_failures untyped
	`mysql_global_status_wsrep_local_cert_failures 0`

