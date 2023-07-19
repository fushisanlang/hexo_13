---
title: ftp_monitor_in.sh
date: 2022-7-12
tags:
  - shell
categories:
  - demo
abbrlink: 453bf668
---

```shell
#!/bin/bash

#######################
#for monitor ftp service
#by zhangyin
#file inner
#version 1
#date 2020 01 03
#######################

#ftp info

##shengchan peizhi
#Ftp_readHost: 192.2.102.211
#Ftp_readPort: 21
#Ftp_readUserName: susong
#Ftp_readPassword: QingDun0909
#Ftp_readBasePath: /
#
#Ftp_writeHost: 192.2.102.212
#Ftp_writePort: 21
#Ftp_writeUserName: susong
#Ftp_writePassword: QingDun0909
#Ftp_writeBasePath: /

Ftp_readHost: 127.0.0.1
Ftp_readPort: 21
Ftp_readUserName: aegisops
Ftp_readPassword: aegisops
Ftp_readBasePath: data

Ftp_writeHost: 127.0.0.1
Ftp_writePort: 21
Ftp_writeUserName: aegisops
Ftp_writePassword: aegisops
Ftp_writeBasePath: data


Work_dir="/tmp/ftp_monitor/"
Input_file=${Work_dir}Input.file
Inner_info="INNERINFO"
Inner_error="INNERERROR"

echo `date +%s` > ${Input_file}
echo 'outter' >> ${Input_file}

mkdir -p ${Work_dir}

cd ${Work_dir}
rm -fr ${Input_file}
ftp -i -n  ${Ftp_readHost} << EOF
user ${Ftp_readUserName} ${Ftp_readPassword}
cd ${Ftp_readBasePath}
get ${Input_file}
del ${Input_file}
EOF
if [[ -e ${Input_file} ]]; then
	echo "${Inner_info}" >> ${Input_file}
	echo `date +%s` >> ${Input_file}
else
	echo "${Inner_error}" >> ${Input_file}
	echo `date +%s` >> ${Input_file}
fi

ftp -i -n  ${Ftp_writeHost} << EOF
user ${Ftp_writeUserName} ${Ftp_writePassword}
cd ${Ftp_writeBasePath}
put ${Input_file}
EOF

```