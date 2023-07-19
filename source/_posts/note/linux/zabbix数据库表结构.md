---
title: zabbix数据库表结构
date: 2020-1-21
updated: 2020-1-22
categories:
  - note
tags:
  - mysql
  - zabbix
abbrlink: 211b3eb9
---
```
	
	mysql> show tables;
	+-----------------------+
	| Tables_in_zabbix      |
	+-----------------------+
	| acknowledges          |
	| actions               |
	| alerts                |
	| application_template  |
	| applications          |
	| auditlog              |
	| auditlog_details      |
	| autoreg_host          |
	| conditions            |
	| config                |
	| dbversion             |
	| dchecks               |
	| dhosts                |
	| drules                |
	| dservices             |
	| escalations           |
	| events                |
	| expressions           |
	| functions             |
	| globalmacro           |
	| globalvars            |
	| graph_discovery       |
	| graph_theme           |
	| graphs                |
	| graphs_items          |
	| group_discovery       |
	| group_prototype       |
	| groups                |
	| history               |
	| history_log           |
	| history_str           |
	| history_text          |
	| history_uint          |
	| host_discovery        |
	| host_inventory        |
	| hostmacro             |
	| hosts                 |
	| hosts_groups          |
	| hosts_templates       |
	| housekeeper           |
	| httpstep              |
	| httpstepitem          |
	| httptest              |
	| httptestitem          |
	| icon_map              |
	| icon_mapping          |
	| ids                   |
	| images                |
	| interface             |
	| interface_discovery   |
	| item_condition        |
	| item_discovery        |
	| items                 |
	| items_applications    |
	| maintenances          |
	| maintenances_groups   |
	| maintenances_hosts    |
	| maintenances_windows  |
	| mappings              |
	| media                 |
	| media_type            |
	| opcommand             |
	| opcommand_grp         |
	| opcommand_hst         |
	| opconditions          |
	| operations            |
	| opgroup               |
	| opmessage             |
	| opmessage_grp         |
	| opmessage_usr         |
	| optemplate            |
	| profiles              |
	| proxy_autoreg_host    |
	| proxy_dhistory        |
	| proxy_history         |
	| regexps               |
	| rights                |
	| screens               |
	| screens_items         |
	| scripts               |
	| service_alarms        |
	| services              |
	| services_links        |
	| services_times        |
	| sessions              |
	| slides                |
	| slideshows            |
	| sysmap_element_url    |
	| sysmap_url            |
	| sysmaps               |
	| sysmaps_elements      |
	| sysmaps_link_triggers |
	| sysmaps_links         |
	| timeperiods           |
	| trends                |
	| trends_uint           |
	| trigger_depends       |
	| trigger_discovery     |
	| triggers              |
	| user_history          |
	| users                 |
	| users_groups          |
	| usrgrp                |
	| valuemaps             |
	+-----------------------+
* actions
	
	actions表记录了当触发器触发时，需要采用的动作。

	
	mysql> desc actions;
	+---------------+---------------------+------+-----+---------+-------+
	| Field         | Type                | Null | Key | Default | Extra |
	+---------------+---------------------+------+-----+---------+-------+
	| actionid      | bigint(20) unsigned | NO   | PRI | 0       |       |
	| name          | varchar(255)        | NO   |     |         |       |
	| eventsource   | int(11)             | NO   | MUL | 0       |       |
	| evaltype      | int(11)             | NO   |     | 0       |       |
	| status        | int(11)             | NO   |     | 0       |       |
	| esc_period    | int(11)             | NO   |     | 0       |       |
	| def_shortdata | varchar(255)        | NO   |     |         |       |
	| def_longdata  | blob                | NO   |     | NULL    |       |
	| recovery_msg  | int(11)             | NO   |     | 0       |       |
	| r_shortdata   | varchar(255)        | NO   |     |         |       |
	| r_longdata    | blob                | NO   |     | NULL    |       |
	+---------------+---------------------+------+-----+---------+-------+

* alerts
	
	alerts 表保存了历史的告警事件，可以从这个表里面去做一些统计分析，例如某个部门、 
	某人、某类时间的告警统计，以及更深入的故障发生、恢复时间，看你想怎么用了。
	

	mysql> desc alerts;
	+-------------+---------------------+------+-----+---------+-------+
	| Field       | Type                | Null | Key | Default | Extra |
	+-------------+---------------------+------+-----+---------+-------+
	| alertid     | bigint(20) unsigned | NO   | PRI | 0       |       |
	| actionid    | bigint(20) unsigned | NO   | MUL | 0       |       |
	| eventid     | bigint(20) unsigned | NO   | MUL | 0       |       |
	| userid      | bigint(20) unsigned | NO   | MUL | 0       |       |
	| clock       | int(11)             | NO   | PRI | 0       |       |
	| mediatypeid | bigint(20) unsigned | NO   | MUL | 0       |       |
	| sendto      | varchar(100)        | NO   |     |         |       |
	| subject     | varchar(255)        | NO   |     |         |       |
	| message     | blob                | NO   |     | NULL    |       |
	| status      | int(11)             | NO   | MUL | 0       |       |
	| retries     | int(11)             | NO   |     | 0       |       |
	| error       | varchar(128)        | NO   |     |         |       |
	| nextcheck   | int(11)             | NO   |     | 0       |       |
	| esc_step    | int(11)             | NO   |     | 0       |       |
	| alerttype   | int(11)             | NO   |     | 0       |       |
	+-------------+---------------------+------+-----+---------+-------+

* config
	
	config表保存了全局的参数，前端包括后端也是，很多情况下会查询改表的参数的，例如用户的自定义主题、 
	登陆认证类型等，非常重要，
	
	不过对我们做数据分析意义不大。

	
	mysql> desc config;
	+-------------------------+---------------------+------+-----+-----------------+-------+
	| Field                   | Type                | Null | Key | Default         | Extra |
	+-------------------------+---------------------+------+-----+-----------------+-------+
	| configid                | bigint(20) unsigned | NO   | PRI | 0               |       |
	| alert_history           | int(11)             | NO   |     | 0               |       |
	| event_history           | int(11)             | NO   |     | 0               |       |
	| refresh_unsupported     | int(11)             | NO   |     | 0               |       |
	| work_period             | varchar(100)        | NO   |     | 1-5,00:00-24:00 |       |
	| alert_usrgrpid          | bigint(20) unsigned | NO   |     | 0               |       |
	| event_ack_enable        | int(11)             | NO   |     | 1               |       |
	| event_expire            | int(11)             | NO   |     | 7               |       |
	| event_show_max          | int(11)             | NO   |     | 100             |       |
	| default_theme           | varchar(128)        | NO   |     | default.css     |       |
	| authentication_type     | int(11)             | NO   |     | 0               |       |
	| ldap_host               | varchar(255)        | NO   |     |                 |       |
	| ldap_port               | int(11)             | NO   |     | 389             |       |
	| ldap_base_dn            | varchar(255)        | NO   |     |                 |       |
	| ldap_bind_dn            | varchar(255)        | NO   |     |                 |       |
	| ldap_bind_password      | varchar(128)        | NO   |     |                 |       |
	| ldap_search_attribute   | varchar(128)        | NO   |     |                 |       |
	| dropdown_first_entry    | int(11)             | NO   |     | 1               |       |
	| dropdown_first_remember | int(11)             | NO   |     | 1               |       |
	| discovery_groupid       | bigint(20) unsigned | NO   |     | 0               |       |
	| max_in_table            | int(11)             | NO   |     | 50              |       |
	| search_limit            | int(11)             | NO   |     | 1000            |       |
	+-------------------------+---------------------+------+-----+-----------------+-------+

*	functions
	
	function 表时非常重要的一个表了，记录了trigger中使用的表达式，例如max、last、nodata等函数。
	
	但其实这个表说他重要时因为同时记录了trigger、itemid，那就可以做一些API的开发了，例如根据 
	IP 茶香改IP的所有trigger，我记得1.8的版本的API是无法实现我说的这个功能的，那只能利用 
	function表去自己查询了。

	
	mysql> desc functions ;
	+------------+---------------------+------+-----+---------+-------+
	| Field      | Type                | Null | Key | Default | Extra |
	+------------+---------------------+------+-----+---------+-------+
	| functionid | bigint(20) unsigned | NO   | PRI | 0       |       |
	| itemid     | bigint(20) unsigned | NO   | MUL | 0       |       |
	| triggerid  | bigint(20) unsigned | NO   | MUL | 0       |       |
	| lastvalue  | varchar(255)        | YES  |     | NULL    |       |
	| function   | varchar(12)         | NO   |     |         |       |
	| parameter  | varchar(255)        | NO   |     | 0       |       |
	+------------+---------------------+------+-----+---------+-------+

*	graphs
	
	graphs 表包含了用户定义的图表信息，同样的玩法可以是根据IP去查询改IP下的所有图表， 
	不过似乎是有API的，我只是举例而已。
	

	mysql> desc graphs;
	+------------------+---------------------+------+-----+---------+-------+
	| Field            | Type                | Null | Key | Default | Extra |
	+------------------+---------------------+------+-----+---------+-------+
	| graphid          | bigint(20) unsigned | NO   | PRI | 0       |       |
	| name             | varchar(128)        | NO   | MUL |         |       |
	| width            | int(11)             | NO   |     | 0       |       |
	| height           | int(11)             | NO   |     | 0       |       |
	| yaxismin         | double(16,4)        | NO   |     | 0.0000  |       |
	| yaxismax         | double(16,4)        | NO   |     | 0.0000  |       |
	| templateid       | bigint(20) unsigned | NO   |     | 0       |       |
	| show_work_period | int(11)             | NO   |     | 1       |       |
	| show_triggers    | int(11)             | NO   |     | 1       |       |
	| graphtype        | int(11)             | NO   |     | 0       |       |
	| show_legend      | int(11)             | NO   |     | 0       |       |
	| show_3d          | int(11)             | NO   |     | 0       |       |
	| percent_left     | double(16,4)        | NO   |     | 0.0000  |       |
	| percent_right    | double(16,4)        | NO   |     | 0.0000  |       |
	| ymin_type        | int(11)             | NO   |     | 0       |       |
	| ymax_type        | int(11)             | NO   |     | 0       |       |
	| ymin_itemid      | bigint(20) unsigned | NO   |     | 0       |       |
	| ymax_itemid      | bigint(20) unsigned | NO   |     | 0       |       |
	+------------------+---------------------+------+-----+---------+-------+

*	graphs_items
	
	graphs_items 保存了属于某个图表的所有的监控项信息。
	

	mysql> desc graphs_items;
	+-------------+---------------------+------+-----+---------+-------+
	| Field       | Type                | Null | Key | Default | Extra |
	+-------------+---------------------+------+-----+---------+-------+
	| gitemid     | bigint(20) unsigned | NO   | PRI | 0       |       |
	| graphid     | bigint(20) unsigned | NO   | MUL | 0       |       |
	| itemid      | bigint(20) unsigned | NO   | MUL | 0       |       |
	| drawtype    | int(11)             | NO   |     | 0       |       |
	| sortorder   | int(11)             | NO   |     | 0       |       |
	| color       | varchar(6)          | NO   |     | 009600  |       |
	| yaxisside   | int(11)             | NO   |     | 1       |       |
	| calc_fnc    | int(11)             | NO   |     | 2       |       |
	| type        | int(11)             | NO   |     | 0       |       |
	| periods_cnt | int(11)             | NO   |     | 5       |       |
	+-------------+---------------------+------+-----+---------+-------+
*	groups
	
	groups 没啥说的，都懂，就是保存了组名和组的ID 。

	
	mysql> desc groups ;
	+----------+---------------------+------+-----+---------+-------+
	| Field    | Type                | Null | Key | Default | Extra |
	+----------+---------------------+------+-----+---------+-------+
	| groupid  | bigint(20) unsigned | NO   | PRI | 0       |       |
	| name     | varchar(64)         | NO   | MUL |         |       |
	| internal | int(11)             | NO   |     | 0       |       |
	+----------+---------------------+------+-----+---------+-------+

*	history 、history_str、history_log 、history_uint_sync等
	
	这部分表都差不多，唯一不同的是保存的数据类型，history_str保存的数据 
	类型就算str即字符类型的。这个是和采集时设置的数据类型一致的。
	
	需要注意的时，因为history表有这么多的类型，那自己写报表系统等去查询 
	数据时，就需要判断下数据的采集类型，如果查错了表，那肯定时没有数据的。
	

	mysql> desc history;
	+--------+---------------------+------+-----+---------+-------+
	| Field  | Type                | Null | Key | Default | Extra |
	+--------+---------------------+------+-----+---------+-------+
	| itemid | bigint(20) unsigned | NO   | PRI | 0       |       |
	| clock  | int(11)             | NO   | PRI | 0       |       |
	| value  | double(16,4)        | NO   |     | 0.0000  |       |
	+--------+---------------------+------+-----+---------+-------+
	
	mysql> desc history_str;
	+--------+---------------------+------+-----+---------+-------+
	| Field  | Type                | Null | Key | Default | Extra |
	+--------+---------------------+------+-----+---------+-------+
	| itemid | bigint(20) unsigned | NO   | MUL | 0       |       |
	| clock  | int(11)             | NO   |     | 0       |       |
	| value  | varchar(255)        | NO   |     |         |       |
	+--------+---------------------+------+-----+---------+-------+

	接收item值时的时间值存放在两个字段内，大于1秒的部分存放找clock字段单位是秒(s)，小于一秒的部分存放在ns字段单位是纳秒(ns)。
	
	两个字段相加的值才是接收item值时的时间值，一般不用关心小于1秒的部分。
	
*	trends、trends_uint
	
	trends 也是保存了历史数据用的，和history不同的时，trends表仅仅保存了 
	小时平均的值，即你可以理解为是history表的数据压缩。所以trends表也有 
	很多的类型，对应history。
	
	值的注意的trends和history表这两类表数据量都非常大，我们一天大概就要有 
	40G 的数据。
	
	所以注意定是去做压缩、删除。
	

	mysql> desc trends;
	+-----------+---------------------+------+-----+---------+-------+
	| Field     | Type                | Null | Key | Default | Extra |
	+-----------+---------------------+------+-----+---------+-------+
	| itemid    | bigint(20) unsigned | NO   | PRI | 0       |       |
	| clock     | int(11)             | NO   | PRI | 0       |       |
	| num       | int(11)             | NO   |     | 0       |       |
	| value_min | double(16,4)        | NO   |     | 0.0000  |       |
	| value_avg | double(16,4)        | NO   |     | 0.0000  |       |
	| value_max | double(16,4)        | NO   |     | 0.0000  |       |
	+-----------+---------------------+------+-----+---------+-------+
	
	mysql> desc trends_uint;
	+-----------+---------------------+------+-----+---------+-------+
	| Field     | Type                | Null | Key | Default | Extra |
	+-----------+---------------------+------+-----+---------+-------+
	| itemid    | bigint(20) unsigned | NO   | PRI | 0       |       |
	| clock     | int(11)             | NO   | PRI | 0       |       |
	| num       | int(11)             | NO   |     | 0       |       |
	| value_min | bigint(20) unsigned | NO   |     | 0       |       |
	| value_avg | bigint(20) unsigned | NO   |     | 0       |       |
	| value_max | bigint(20) unsigned | NO   |     | 0       |       |
	+-----------+---------------------+------+-----+---------+-------+

*	hosts
	
	hosts 非常重要，保存了每个agent、proxy等的IP 、hostid、状态、IPMI等信息， 
	几乎是记录了一台设备的所有的信息。
	
	当然hostid是当中非常非常重要的信息，其他的表一般都时关联hostid的。
	

	mysql> desc hosts;
	+--------------------+---------------------+------+-----+-----------+-------+
	| Field              | Type                | Null | Key | Default   | Extra |
	+--------------------+---------------------+------+-----+-----------+-------+
	| hostid             | bigint(20) unsigned | NO   | PRI | 0         |       |
	| proxy_hostid       | bigint(20) unsigned | NO   | MUL | 0         |       |
	| host               | varchar(64)         | NO   | MUL |           |       |
	| dns                | varchar(64)         | NO   |     |           |       |
	| useip              | int(11)             | NO   |     | 1         |       |
	| ip                 | varchar(39)         | NO   |     | 127.0.0.1 |       |
	| port               | int(11)             | NO   |     | 10050     |       |
	| status             | int(11)             | NO   | MUL | 0         |       |
	| disable_until      | int(11)             | NO   |     | 0         |       |
	| error              | varchar(128)        | NO   |     |           |       |
	| available          | int(11)             | NO   |     | 0         |       |
	| errors_from        | int(11)             | NO   |     | 0         |       |
	| lastaccess         | int(11)             | NO   |     | 0         |       |
	| inbytes            | bigint(20) unsigned | NO   |     | 0         |       |
	| outbytes           | bigint(20) unsigned | NO   |     | 0         |       |
	| useipmi            | int(11)             | NO   |     | 0         |       |
	| ipmi_port          | int(11)             | NO   |     | 623       |       |
	| ipmi_authtype      | int(11)             | NO   |     | 0         |       |
	| ipmi_privilege     | int(11)             | NO   |     | 2         |       |
	| ipmi_username      | varchar(16)         | NO   |     |           |       |
	| ipmi_password      | varchar(20)         | NO   |     |           |       |
	| ipmi_disable_until | int(11)             | NO   |     | 0         |       |
	| ipmi_available     | int(11)             | NO   |     | 0         |       |
	| snmp_disable_until | int(11)             | NO   |     | 0         |       |
	| snmp_available     | int(11)             | NO   |     | 0         |       |
	| maintenanceid      | bigint(20) unsigned | NO   |     | 0         |       |
	| maintenance_status | int(11)             | NO   |     | 0         |       |
	| maintenance_type   | int(11)             | NO   |     | 0         |       |
	| maintenance_from   | int(11)             | NO   |     | 0         |       |
	| ipmi_ip            | varchar(64)         | NO   |     | 127.0.0.1 |       |
	| ipmi_errors_from   | int(11)             | NO   |     | 0         |       |
	| snmp_errors_from   | int(11)             | NO   |     | 0         |       |
	| ipmi_error         | varchar(128)        | NO   |     |           |       |
	| snmp_error         | varchar(128)        | NO   |     |           |       |
	+--------------------+---------------------+------+-----+-----------+-------+
	其实1.0的版本中，是没有这么多的字段的，好像只有hostid、host、status、disable_until 
	等几个字段，但1.8已经如此丰富了。
	
*	hosts_groups
	
	hosts_groups 保存了host（主机）与host groups（主机组）的关联关系。
	
	这部分信息可以在我们自己做一些批量查询，例如查询关联到某个主机组的所有 
	设备的IP 、存活状态等，进一步去查询该批量设备的load、IO、mem等统计信息。
	
	我之前做的一个简单的报表就是例如了这部分的信息去查询某个业务线下所有设备 
	的一周统计信息，当然了是在同一个主机组或者模版组才可以的。
	

	mysql> desc hosts_groups ;
	+-------------+---------------------+------+-----+---------+-------+
	| Field       | Type                | Null | Key | Default | Extra |
	+-------------+---------------------+------+-----+---------+-------+
	| hostgroupid | bigint(20) unsigned | NO   | PRI | 0       |       |
	| hostid      | bigint(20) unsigned | NO   | MUL | 0       |       |
	| groupid     | bigint(20) unsigned | NO   | MUL | 0       |       |
	+-------------+---------------------+------+-----+---------+-------+
*	items
	
	items 表保存了采集项的信息。
	

	mysql> desc items ;
	+-----------------------+---------------------+------+-----+---------+-------+
	| Field                 | Type                | Null | Key | Default | Extra |
	+-----------------------+---------------------+------+-----+---------+-------+
	| itemid                | bigint(20) unsigned | NO   | PRI | 0       |       |
	| type                  | int(11)             | NO   |     | 0       |       |
	| snmp_community        | varchar(64)         | NO   |     |         |       |
	| snmp_oid              | varchar(255)        | NO   |     |         |       |
	| snmp_port             | int(11)             | NO   |     | 161     |       |
	| hostid                | bigint(20) unsigned | NO   | MUL | 0       |       |
	| description           | varchar(255)        | NO   |     |         |       |
	| key_                  | varchar(255)        | NO   |     |         |       |
	| delay                 | int(11)             | NO   |     | 0       |       |
	| history               | int(11)             | NO   |     | 90      |       |
	| trends                | int(11)             | NO   |     | 365     |       |
	| lastvalue             | varchar(255)        | YES  |     | NULL    |       |
	| lastclock             | int(11)             | YES  |     | NULL    |       |
	| prevvalue             | varchar(255)        | YES  |     | NULL    |       |
	| status                | int(11)             | NO   | MUL | 0       |       |
	| value_type            | int(11)             | NO   |     | 0       |       |
	| trapper_hosts         | varchar(255)        | NO   |     |         |       |
	| units                 | varchar(10)         | NO   |     |         |       |
	| multiplier            | int(11)             | NO   |     | 0       |       |
	| delta                 | int(11)             | NO   |     | 0       |       |
	| prevorgvalue          | varchar(255)        | YES  |     | NULL    |       |
	| snmpv3_securityname   | varchar(64)         | NO   |     |         |       |
	| snmpv3_securitylevel  | int(11)             | NO   |     | 0       |       |
	| snmpv3_authpassphrase | varchar(64)         | NO   |     |         |       |
	| snmpv3_privpassphrase | varchar(64)         | NO   |     |         |       |
	| formula               | varchar(255)        | NO   |     | 1       |       |
	| error                 | varchar(128)        | NO   |     |         |       |
	| lastlogsize           | int(11)             | NO   |     | 0       |       |
	| logtimefmt            | varchar(64)         | NO   |     |         |       |
	| templateid            | bigint(20) unsigned | NO   | MUL | 0       |       |
	| valuemapid            | bigint(20) unsigned | NO   |     | 0       |       |
	| delay_flex            | varchar(255)        | NO   |     |         |       |
	| params                | text                | NO   |     | NULL    |       |
	| ipmi_sensor           | varchar(128)        | NO   |     |         |       |
	| data_type             | int(11)             | NO   |     | 0       |       |
	| authtype              | int(11)             | NO   |     | 0       |       |
	| username              | varchar(64)         | NO   |     |         |       |
	| password              | varchar(64)         | NO   |     |         |       |
	| publickey             | varchar(64)         | NO   |     |         |       |
	| privatekey            | varchar(64)         | NO   |     |         |       |
	| mtime                 | int(11)             | NO   |     | 0       |       |
	+-----------------------+---------------------+------+-----+---------+-------+
*	media
	
	media 保存了某个用户的media配置项，即对应的告警方式。
	

	mysql> desc media;
	+-------------+---------------------+------+-----+-----------------+-------+
	| Field       | Type                | Null | Key | Default         | Extra |
	+-------------+---------------------+------+-----+-----------------+-------+
	| mediaid     | bigint(20) unsigned | NO   | PRI | 0               |       |
	| userid      | bigint(20) unsigned | NO   | MUL | 0               |       |
	| mediatypeid | bigint(20) unsigned | NO   | MUL | 0               |       |
	| sendto      | varchar(100)        | NO   |     |                 |       |
	| active      | int(11)             | NO   |     | 0               |       |
	| severity    | int(11)             | NO   |     | 63              |       |
	| period      | varchar(100)        | NO   |     | 1-7,00:00-23:59 |       |
	+-------------+---------------------+------+-----+-----------------+-------+
*	media_type
	
	media_type 表与media 表不同的是media_type 记录了某个告警方式对应的脚步等的存放路径。
	

	mysql> desc media_type;
	+-------------+---------------------+------+-----+---------+-------+
	| Field       | Type                | Null | Key | Default | Extra |
	+-------------+---------------------+------+-----+---------+-------+
	| mediatypeid | bigint(20) unsigned | NO   | PRI | 0       |       |
	| type        | int(11)             | NO   |     | 0       |       |
	| description | varchar(100)        | NO   |     |         |       |
	| smtp_server | varchar(255)        | NO   |     |         |       |
	| smtp_helo   | varchar(255)        | NO   |     |         |       |
	| smtp_email  | varchar(255)        | NO   |     |         |       |
	| exec_path   | varchar(255)        | NO   |     |         |       |
	| gsm_modem   | varchar(255)        | NO   |     |         |       |
	| username    | varchar(255)        | NO   |     |         |       |
	| passwd      | varchar(255)        | NO   |     |         |       |
	+-------------+---------------------+------+-----+---------+-------+
	media 与media_type 通过mediatypeid 键关联。
	
*	profiles
	
	profiles 表保存了用户的一些配置项。
	

	mysql> desc profiles ;
	+-----------+---------------------+------+-----+---------+-------+
	| Field     | Type                | Null | Key | Default | Extra |
	+-----------+---------------------+------+-----+---------+-------+
	| profileid | bigint(20) unsigned | NO   | PRI | 0       |       |
	| userid    | bigint(20) unsigned | NO   | MUL | 0       |       |
	| idx       | varchar(96)         | NO   |     |         |       |
	| idx2      | bigint(20) unsigned | NO   |     | 0       |       |
	| value_id  | bigint(20) unsigned | NO   |     | 0       |       |
	| value_int | int(11)             | NO   |     | 0       |       |
	| value_str | varchar(255)        | NO   |     |         |       |
	| source    | varchar(96)         | NO   |     |         |       |
	| type      | int(11)             | NO   |     | 0       |       |
	+-----------+---------------------+------+-----+---------+-------+
*	rights
	
	rights 表保存了用户组的权限信息，zabbix的权限一直也是我理不太清的地方， 
	其实这个表里面有详细的记录。
	

	mysql> desc rights;
	+------------+---------------------+------+-----+---------+-------+
	| Field      | Type                | Null | Key | Default | Extra |
	+------------+---------------------+------+-----+---------+-------+
	| rightid    | bigint(20) unsigned | NO   | PRI | 0       |       |
	| groupid    | bigint(20) unsigned | NO   | MUL | 0       |       |
	| permission | int(11)             | NO   |     | 0       |       |
	| id         | bigint(20) unsigned | YES  | MUL | NULL    |       |
	+------------+---------------------+------+-----+---------+-------+
*	screens
	
	screens 表保存了用户定义的图片。
	

	mysql> desc graphs;
	+------------------+---------------------+------+-----+---------+-------+
	| Field            | Type                | Null | Key | Default | Extra |
	+------------------+---------------------+------+-----+---------+-------+
	| graphid          | bigint(20) unsigned | NO   | PRI | 0       |       |
	| name             | varchar(128)        | NO   | MUL |         |       |
	| width            | int(11)             | NO   |     | 0       |       |
	| height           | int(11)             | NO   |     | 0       |       |
	| yaxismin         | double(16,4)        | NO   |     | 0.0000  |       |
	| yaxismax         | double(16,4)        | NO   |     | 0.0000  |       |
	| templateid       | bigint(20) unsigned | NO   |     | 0       |       |
	| show_work_period | int(11)             | NO   |     | 1       |       |
	| show_triggers    | int(11)             | NO   |     | 1       |       |
	| graphtype        | int(11)             | NO   |     | 0       |       |
	| show_legend      | int(11)             | NO   |     | 0       |       |
	| show_3d          | int(11)             | NO   |     | 0       |       |
	| percent_left     | double(16,4)        | NO   |     | 0.0000  |       |
	| percent_right    | double(16,4)        | NO   |     | 0.0000  |       |
	| ymin_type        | int(11)             | NO   |     | 0       |       |
	| ymax_type        | int(11)             | NO   |     | 0       |       |
	| ymin_itemid      | bigint(20) unsigned | NO   |     | 0       |       |
	| ymax_itemid      | bigint(20) unsigned | NO   |     | 0       |       |
	+------------------+---------------------+------+-----+---------+-------+
*	screens_items
	
	同graphs_items。

	
	mysql> desc screens_items;
	+--------------+---------------------+------+-----+---------+-------+
	| Field        | Type                | Null | Key | Default | Extra |
	+--------------+---------------------+------+-----+---------+-------+
	| screenitemid | bigint(20) unsigned | NO   | PRI | 0       |       |
	| screenid     | bigint(20) unsigned | NO   |     | 0       |       |
	| resourcetype | int(11)             | NO   |     | 0       |       |
	| resourceid   | bigint(20) unsigned | NO   |     | 0       |       |
	| width        | int(11)             | NO   |     | 320     |       |
	| height       | int(11)             | NO   |     | 200     |       |
	| x            | int(11)             | NO   |     | 0       |       |
	| y            | int(11)             | NO   |     | 0       |       |
	| colspan      | int(11)             | NO   |     | 0       |       |
	| rowspan      | int(11)             | NO   |     | 0       |       |
	| elements     | int(11)             | NO   |     | 25      |       |
	| valign       | int(11)             | NO   |     | 0       |       |
	| halign       | int(11)             | NO   |     | 0       |       |
	| style        | int(11)             | NO   |     | 0       |       |
	| url          | varchar(255)        | NO   |     |         |       |
	| dynamic      | int(11)             | NO   |     | 0       |       |
	+--------------+---------------------+------+-----+---------+-------+
*	sessions
	
	sessions 表很重要，保存了每个用户的sessions,在登陆、注销的时候均会操作 
	该张表的。


	
	mysql> desc sessions;
	+------------+---------------------+------+-----+---------+-------+
	| Field      | Type                | Null | Key | Default | Extra |
	+------------+---------------------+------+-----+---------+-------+
	| sessionid  | varchar(32)         | NO   | PRI |         |       |
	| userid     | bigint(20) unsigned | NO   | MUL | 0       |       |
	| lastaccess | int(11)             | NO   |     | 0       |       |
	| status     | int(11)             | NO   |     | 0       |       |
	+------------+---------------------+------+-----+---------+-------+

*	triggers
	
	triggers 顾名思义保存了trigger的所有信息。
	

	mysql> desc triggers;
	+-------------+---------------------+------+-----+---------+-------+
	| Field       | Type                | Null | Key | Default | Extra |
	+-------------+---------------------+------+-----+---------+-------+
	| triggerid   | bigint(20) unsigned | NO   | PRI | 0       |       |
	| expression  | varchar(255)        | NO   |     |         |       |
	| description | varchar(255)        | NO   |     |         |       |
	| url         | varchar(255)        | NO   |     |         |       |
	| status      | int(11)             | NO   | MUL | 0       |       |
	| value       | int(11)             | NO   | MUL | 0       |       |
	| priority    | int(11)             | NO   |     | 0       |       |
	| lastchange  | int(11)             | NO   |     | 0       |       |
	| dep_level   | int(11)             | NO   |     | 0       |       |
	| comments    | blob                | NO   |     | NULL    |       |
	| error       | varchar(128)        | NO   |     |         |       |
	| templateid  | bigint(20) unsigned | NO   |     | 0       |       |
	| type        | int(11)             | NO   |     | 0       |       |
	+-------------+---------------------+------+-----+---------+-------+
*	trigger_depends
	
	trigger_depends 保存了trigger的依赖关系。
	

	mysql> desc trigger_depends;
	+----------------+---------------------+------+-----+---------+-------+
	| Field          | Type                | Null | Key | Default | Extra |
	+----------------+---------------------+------+-----+---------+-------+
	| triggerdepid   | bigint(20) unsigned | NO   | PRI | 0       |       |
	| triggerid_down | bigint(20) unsigned | NO   | MUL | 0       |       |
	| triggerid_up   | bigint(20) unsigned | NO   | MUL | 0       |       |
	+----------------+---------------------+------+-----+---------+-------+
*	users
	
	不需要解释了,值的一提的部分用户配置会在该表中，例如auotlogin、autologout、 
	url、theme等信息。
	

	mysql> desc users;
	+----------------+---------------------+------+-----+-------------+-------+
	| Field          | Type                | Null | Key | Default     | Extra |
	+----------------+---------------------+------+-----+-------------+-------+
	| userid         | bigint(20) unsigned | NO   | PRI | 0           |       |
	| alias          | varchar(100)        | NO   | MUL |             |       |
	| name           | varchar(100)        | NO   |     |             |       |
	| surname        | varchar(100)        | NO   |     |             |       |
	| passwd         | char(32)            | NO   |     |             |       |
	| url            | varchar(255)        | NO   |     |             |       |
	| autologin      | int(11)             | NO   |     | 0           |       |
	| autologout     | int(11)             | NO   |     | 900         |       |
	| lang           | varchar(5)          | NO   |     | en_gb       |       |
	| refresh        | int(11)             | NO   |     | 30          |       |
	| type           | int(11)             | NO   |     | 0           |       |
	| theme          | varchar(128)        | NO   |     | default.css |       |
	| attempt_failed | int(11)             | NO   |     | 0           |       |
	| attempt_ip     | varchar(39)         | NO   |     |             |       |
	| attempt_clock  | int(11)             | NO   |     | 0           |       |
	| rows_per_page  | int(11)             | NO   |     | 50          |       |
	+----------------+---------------------+------+-----+-------------+-------+

```