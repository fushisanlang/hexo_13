---
title: Xtra_QSDB_His_Load.sh
date: 2022-7-12
tags:
  - shell
categories:
  - demo
abbrlink: fbb28696
---

```shell
#!/bin/bash
#set -x
tgtlist="192.168.66.3:JSPT"
Logdate=`date "+%Y-%m-%d"`
Lastday=`date -d "- 1 day" "+%Y-%m-%d"`
bakup_dir=/data/dbbackup/jspt/
#判断当日属于周几
Dayofweek=`date "+%w"`
if [ $Dayofweek -eq 0 ];then Dayofweek=7;fi
cnf_dir=/data/shell/my.cnf
his_dir=/data/his_data/
Mysql_dir=/data/mysql_3307
Base_date=`date -d "- \`expr ${Dayofweek} - 1\` day" "+%Y-%m-%d"`
log_type=log
logfile=${his_dir}JSPT_${Logdate}.${log_type}
user=root
paswd=qaz000123

function print_log(){
    [ $# -gt 0 ] && log_str="$@" || read log_str </dev/stdin
    local LogDate=`date  "+%Y-%m-%d %H:%M:%S" `	
    local LogStr="[${LogDate}]: ${log_str}"
    echo ${LogStr}>>${logfile}
    echo ${LogStr}
}

function copy_data(){
    local IP=$1
    local Sysname=$2
    local Base_date=`date -d "- 7  day" "+%Y-%m-%d"`
    echo "############## start copy ${Sysname}_${Logdate} ###############" | print_log  
    if [ ${Dayofweek} -eq 1 ] && [ "`ls ${his_dir} |grep ${Base_date} |grep -v ${log_type}`" != "" ];then
        rm -rf ${his_dir}${Sysname}_${Base_date}
    fi
    scp -r -P 60022 ${IP}:${bakup_dir}${Sysname}_${Logdate} ${his_dir}
    if [ $? -ne 0 ];then
        echo "copy ${IP}:${bakup_dir}${Sysname}$_${Logdate} ${his_dir} error " | print_log
        exit 1
    else
        echo "############## finish copy ${Sysname}_${Logdate} ###############" | print_log
    fi
}

function prepare_data(){

    local Sysname=$1
    echo "############## start prepare $1 ###############" | print_log    
    #判断是全量还是增量日
    if [ ${Dayofweek} -eq 1 ] ;then
	Tgt_dir=${his_dir}${Sysname}_${Logdate}
        innobackupex --apply-log ${his_dir}${Sysname}_${Logdate} --use-memory=2G 2>/dev/null
    else

	if [ ${Dayofweek} -eq 2 ];then
	    innobackupex --apply-log --redo-only ${his_dir}${Sysname}_${Base_date} --use-memory=2G 2>/dev/null
	fi

	Tgt_dir=${his_dir}${Sysname}_${Base_date}
	innobackupex --apply-log --redo-only ${his_dir}${Sysname}_${Base_date} --incremental-dir=${his_dir}${Sysname}_${Logdate} --use-memory=2G 2>/dev/null
    fi       
    if [ $? -ne 0 ];then
        echo "prepare $1  error!"| print_log
        exit 1
    else
        echo "############## finish prepare $1 ###############" | print_log
    fi

}

function recovery_data(){

    local Sysname=$1
    echo "############## start recovery ${Sysname} ################" | print_log
    
    while :;do    
	mysqladmin -u${user} -p${paswd} -P3307  -S /var/lib/mysql/mysql_3307.sock  shutdown >/dev/null
	sleep 30
    	if [ "`ps -ef |grep mysql|grep 3307`" == "" ];then
	    break
	fi
    done

    rm -rf ${Mysql_dir}/*
    innobackupex --defaults-file=${cnf_dir} --copy-back ${Tgt_dir} 2>/dev/null
    if [ $? -ne 0 ];then
        echo "innobackupex --defaults-file=${cnf_dir} --copy-back ${Tgt_dir} error!"| print_log
        exit 1
    else    
        echo "innobackupex --defaults-file=${cnf_dir} --copy-back ${Tgt_dir} finish"| print_log
        mkdir ${Mysql_dir}/log
        chown -R mysql:mysql ${Mysql_dir}/*
	chmod -R 660 ${Mysql_dir}/jspt/*
        echo "try start mysql_3307"| print_log
	mysqld_multi start 3307
	while :;do
	    sleep 30
	    if [ "`ps -ef |grep mysql|grep 3307`" != "" ];then
	        cat /data/shell/init.sql |mysql -uroot -pqaz000123 -P3307  -S /var/lib/mysql/mysql_3307.sock -Djspt
		if [ $? -ne 0 ];then
                    echo " cat /data/shell/init.sql |mysql -uroot -pqaz000123 -P3307  -S /var/lib/mysql/mysql_3307.sock -Djspt  error!" | print_log
		    exit 1
		fi
  		break
	    fi
	done
	if [ ${Dayofweek} -ne 1 ] ;then
	    rm -rf ${his_dir}${Sysname}_${Logdate}
        fi
	echo "############## finish recovery ${Sysname} ###############" | print_log
    fi
}

for tgt in $tgtlist; do
    ip=`echo $tgt |awk -F':' '{print $1}'`
    sys_name=`echo $tgt |awk -F':' '{print $2}'`

   copy_data $ip $sys_name
   prepare_data $sys_name
   recovery_data $sys_name 
done
```