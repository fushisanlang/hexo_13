---
title: ETL工具datax kettle对比
tags:
  - datax
  - kettle
  - ETL
categories:
  - note
abbrlink: 38e1dcf6
date: 2021-07-04 00:00:00
---


 1、阿里开源软件： [DataX](http://www.oschina.net/news/76468/datax-3-0?_t_t_t=0.5396898166724515)

​     DataX 是一个异构数据源离线同步工具，致力于实现包括关系型数据库(MySQL、Oracle等)、HDFS、Hive、ODPS、HBase、FTP等各种异构数据源之间稳定高效的数据同步功能。

 2、Apache开源软件： [Sqoop](http://sqoop.apache.org/)

 Sqoop(发音:skup)是一款开源的工具，主要用于在HADOOP(Hive)与传统的数据库(mysql、postgresql...)间进行数据的传递，可以将一个关系型数据库(例如 : MySQL ,Oracle ,Postgres等)中的数据导进到Hadoop的HDFS中，也可以将HDFS的数据导进到关系型数据库中。（摘自百科）

 3、Kettle开源软件：水壶（中文名）

   Kettle是一款国外开源的ETL工具，纯java编写，可以在Window、Linux、Unix上运行，绿色无需安装，数据抽取高效稳定。

 Kettle 中文名称叫水壶，该项目的主程序员MATT 希望把各种数据放到一个壶里，然后以一种指定的格式流出。

 Kettle这个ETL工具集，它允许你管理来自不同数据库的数据，通过提供一个图形化的用户环境来描述你想做什么，而不是你想怎么做。

 Kettle中有两种脚本文件，transformation和job，transformation完成针对数据的基础转换，job则完成整个工作流的控制。

 

 

  **Kettle与DataX的比较：**

  1）Kettle拥有自己的管理控制台，可以直接在客户端进行etl任务制定，不过是CS架构，而不支持BS浏览器模式。DataX并没有界面，界面完全需要自己开发，增加了很大工作量。

  2）Kettle可以与我们自己的工程进行集成，通过JAVA代码集成即可，可以在java中调用kettle的转换、执行、结束等动作，这个还是有意义的，而DataX是不支持的，DataX是以执行脚本的方式运行任务的，当然完全吃透源码的情况下，应该也是可以调用的。

  3）支持的数据库，都支持的比较齐全，kettle支持的应该更多，DataX是阿里开发，可以更好地支持阿里自身的数据库系列，如ODPS、ADS等

  4）Kettle已经加入BI组织Pentaho，加入后kettle的开发粒度和被关注度更进一步提升

  5）DataX开源的支持粒度不高，关注度远没有kettle高，代码提交次数更是少的很。

   