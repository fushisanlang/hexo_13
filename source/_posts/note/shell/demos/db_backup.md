---
title: db_backup.sh
date: 2022-7-12
tags:
  - shell
categories:
  - demo
abbrlink: 893aa454
---

```shell
#!/bin/bash

#########
#for bak up mysql databases
#by zhangying@aegis-data.cn
#version 1
#date 2019-12-24
#########

#parameter
Base_dir="/data/mysql_bak/"
Note_file=${Base_dir}notefile
Date=`date +%Y%m%d`
Bak_dir="${Base_dir}${Date}/"
Bak_suffix='_bak_v1.gz'
Bak_log=/tmp/${Date}_dbbak.log

#before
mkdir -p ${Bak_dir}

#bak
cat ${Note_file} | while read line
do
	Db_user=`echo ${line} | awk '{print $1}'`
	Db_pass=`echo ${line} | awk '{print $2}'`
	Db_name=`echo ${line} | awk '{print $3}'`
	mysqldump -u${Db_user} -p${Db_pass} -P3309 --opt --single-transaction -R ${Db_name} | gzip > ${Bak_dir}${Db_name}${Bak_suffix}
	echo ${Bak_dir}${Db_name}${Bak_suffix} >> ${Bak_log}
done
```