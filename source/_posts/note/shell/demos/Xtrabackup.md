---
title: Xtrabackup.sh
date: 2022-7-12
tags:
  - shell
categories:
  - demo
abbrlink: 7ac65b19
---

```shell
#!/bin/bash
#auther lilin
#set -x
Bakupdir= #存放路径
Sysname=  #系统名
#判断当日属于周几
Dayofweek=`date "+%w"`
Lastday=`date -d "- 1 day" "+%Y-%m-%d"`
Logdate=`date "+%Y-%m-%d"`
Logtype=log
User=root
Pswd= ##密码
#mysql配置存放路径
Mycnfpath=/etc/my.cnf
#上一日全量包名
Baseidir=`ls ${Bakupdir} |grep ${Lastday} |grep -v ${Logtype}`
Logfile=${Bakupdir}${Sysname}_${Logdate}.${Logtype}

Old_file_dir= #历史数据路径
#打印日志
function Print_log(){
    [ $# -gt 0 ] && log_str="$@" || read log_str </dev/stdin
    local LogDate=`date  "+%Y-%m-%d %H:%M:%S" `
    local LogStr="[${LogDate}]: ${log_str}"
    echo ${LogStr}>>${Logfile}
    echo ${LogStr}
}


function Bakup(){

    echo "=============================== start backup ================================" | Print_log
    #判断今日是全量日还是增量日 
    if [ ${Dayofweek} -eq 1 ] ;then
        innobackupex --defaults-file=${Mycnfpath} --user=${User} --password=${Pswd} --no-timestamp ${Bakupdir}${Sysname}_${Logdate} 2>${Bakupdir}innobackupex_${Logdate}.${Logtype}
    else
        innobackupex --incremental --no-timestamp ${Bakupdir}${Sysname}_${Logdate} ${Bakupdir} --incremental-basedir=${Bakupdir}${Baseidir} --user=${User} --password=${Pswd} 2>${Bakupdir}innobackupex_${Logdate}.${Logtype}
   fi

    if [ $? -ne 0 ];then
        echo "backup error. see more : ${Bakupdir}innobackupex_${Logdate}.${Logtype}"| Print_log
        exit 1
    fi
	echo "=============================== finish backup ================================" | Print_log
}

function Compress(){

    echo "=============================== start compress ================================" | Print_log
    cd ${Bakupdir}
    #判断备份文件是否存在
    if [ "${Baseidir}" != "" ] && [ -e "${Bakupdir}innobackupex_${Lastday}.${Logtype}" ] && [ -e "${Bakupdir}${Sysname}_${Lastday}.${Logtype}" ];then

	tar -zcvf ${Bakupdir}${Sysname}_${Lastday}.tar.gz ${Bakupdir}${Baseidir} ${Bakupdir}innobackupex_${Lastday}.${Logtype}  ${Bakupdir}${Sysname}_${Lastday}.${Logtype} --remove-files >/dev/null
 
        if [ $? -ne 0 ];then
            echo "compress error."| Print_log
            exit 1
        fi
        echo "=============================== finish compress ================================" | Print_log
    else 
	echo "${Bakupdir}innobackupex_${Lastday}.${Logtype} or ${Bakupdir}${Sysname}_${Lastday}.${Logtype} does not exists!" | Print_log
    fi
}

function Move_old_file(){

    echo "=============================== start move  ================================" | Print_log
    echo "move ${Bakupdir}${Sysname}_${Lastday}.tar.gz to ${Old_file_dir} ..." |Print_log
    if [ -e "${Bakupdir}${Sysname}_${Lastday}.tar.gz" ];then
	#将上一日备份迁移至历史备份路径 
   	mv ${Bakupdir}${Sysname}_${Lastday}.tar.gz   ${Old_file_dir}
    	echo "=============================== finish move  ================================" | Print_log
    else
	echo "${Bakupdir}${Sysname}_${Lastday}.tar.gz  does not exists!" | Print_log
    fi
}

Bakup
Compress
Move_old_file
```