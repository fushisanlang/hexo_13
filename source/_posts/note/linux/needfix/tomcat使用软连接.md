---
title: tomcat使用软连接
date: 2017-5-1
updated: 2017-5-2
categories:
  - note
abbrlink: 16d2ee8b
---
  在context.xml文件中的
<Context>中 
加入
  <Resources allowLinking="true" />
并重启tomcat