---
title: strace命令
date: 2022-2-14
tags:
  - top
categories:
  - note
abbrlink: 6522ca6a
---

## 调用
```
strace [ -dffhiqrtttTvxx ] [ -acolumn ] [ -eexpr ] ...
[ -ofile ] [ -ppid ] ... [ -sstrsize ] [ -uusername ] [ command [ arg ... ] ]
strace -c [ -eexpr ] ... [ -Ooverhead ] [ -Ssortby ] [ command [ arg ... ] ]
```

## 功能
> 跟踪程式执行时的系统调用和所接收的信号.通常的用法是strace执行一直到commande结束. 并且将所调用的系统调用的名称、参数和返回值输出到标准输出或者输出到-o指定的文件. strace是一个功能强大的调试,分析诊断工具.你将发现他是一个极好的帮手在你要调试一个无法看到源码或者源码无法在编译的程序. 你将轻松的学习到一个软件是如何通过系统调用来实现他的功能的.而且作为一个程序设计师,你可以了解到在用户态和内核态是如何通过系统调用和信号来实现程序的功能的.

strace的每一行输出包括系统调用名称,然后是参数和返回值.

```shell 
strace cat /dev/null
open("/dev/null",O_RDONLY) = 3

#有错误产生时,一般会返回-1.所以会有错误标志和描述:
open("/foor/bar",)_RDONLY) = -1 ENOENT (no such file or directory)

#信号将输出喂信号标志和信号的描述.跟踪并中断这个命
sigsuspend({} 
--- SIGINT (Interrupt) --- 
+++ killed by SIGINT +++

#参数的输出有些不一致.如shell命令中的 ">>tmp" ,将输出:
open("tmp",O_WRONLY|O_APPEND|A_CREAT,0666) = 3

#对于结构指针,将进行适当的显示.如:"ls -l /dev/null":
lstat("/dev/null",{st_mode=S_IFCHR|0666},st_rdev=makdev[1,3],...}) = 0

#请注意"struct stat" 的声明和这里的输出.lstat的第一个参数是输入参数,而第二个参数是向外传值.

#当你尝试"ls -l" 一个不存在的文件时,会有:

lstat("/foot/ball",0xb004) = -1 ENOENT (no such file or directory)
#char*将作为C的字符串类型输出.没有字符串输出时一般是char* 是一个转义字符,只输出字符串的长度.

#当字符串过长是会使用"..."省略.如在"ls -l"会有一个gepwuid调用读取password文件:
read(3,"root::0:0:System Administrator:/"...,1024) = 422

#当参数是结构数组时,将按照简单的指针和数组输出如:
getgroups(4,[0,2,4,5]) = 4

#关于bit作为参数的情形,也是使用方括号,并且用空格将每一项参数隔开.如:
sigprocmask(SIG_BLOCK,[CHLD TTOU],[]) = 0

#这里第二个参数代表两个信号SIGCHLD 和 SIGTTOU.

#如果bit型参数全部置位,则有如下的输出:
sigprocmask(SIG_UNBLOCK,~[],NULL) = 0
#这里第二个参数全部置位.
```

## 参数说明
```
-c 统计每一系统调用的所执行的时间,次数和出错的次数等. 
    -d 输出strace关于标准错误的调试信息. 
    -f 跟踪由fork调用所产生的子进程. 
    -ff 如果提供-o filename,则所有进程的跟踪结果输出到相应的filename.pid中,pid是各进程的进程号. 
    -F 尝试跟踪vfork调用.在-f时,vfork不被跟踪. 
    -h 输出简要的帮助信息. 
    -i 输出系统调用的入口指针. 
    -q 禁止输出关于脱离的消息. 
    -r 打印出相对时间关于,,每一个系统调用. 
    -t 在输出中的每一行前加上时间信息. 
    -tt 在输出中的每一行前加上时间信息,微秒级. 
    -ttt 微秒级输出,以秒了表示时间. 
    -T 显示每一调用所耗的时间. 
    -v 输出所有的系统调用.一些调用关于环境变量,状态,输入输出等调用由于使用频繁,默认不输出. 
    -V 输出strace的版本信息. 
    -x 以十六进制形式输出非标准字符串 
    -xx 所有字符串以十六进制形式输出. 
    -a column 
    设置返回值的输出位置.默认为40. 
    -e expr 
    指定一个表达式,用来控制如何跟踪.格式如下: 
    [qualifier=][!]value1[,value2] 
    qualifier只能是 trace,abbrev,verbose,raw,signal,read,write其中之一.value是用来限定的符号或数字.默认的qualifier是 trace.感叹号是否定符号.例如: 
    -eopen等价于 -e trace=open,表示只跟踪open调用.而-etrace!=open表示跟踪除了open以外的其他调用.有两个特殊的符号 all 和 none. 
    注意有些shell使用!来执行历史记录里的命令,所以要使用\\\\. 
    -e trace=set 
    只跟踪指定的系统调用.例如:-e trace=open,close,rean,write表示只跟踪这四个系统调用.默认的为set=all. 
    -e trace=file 
    只跟踪有关文件操作的系统调用. 
    -e trace=process 
    只跟踪有关进程控制的系统调用. 
    -e trace=network 
    跟踪与网络有关的所有系统调用. 
    -e strace=signal 
    跟踪所有与系统信号有关的系统调用 
    -e trace=ipc 
    跟踪所有与进程通讯有关的系统调用 
    -e abbrev=set 
    设定strace输出的系统调用的结果集.-v 等与 abbrev=none.默认为abbrev=all. 
    -e raw=set 
    将指定的系统调用的参数以十六进制显示. 
    -e signal=set 
    指定跟踪的系统信号.默认为all.如signal=!SIGIO(或者signal=!io),表示不跟踪SIGIO信号. 
    -e read=set 
    输出从指定文件中读出的数据.例如: 
    -e read=3,5 
    -e write=set 
    输出写入到指定文件中的数据. 
    -o filename 
    将strace的输出写入文件filename 
    -p pid 
    跟踪指定的进程pid. 
    -s strsize 
    指定输出的字符串的最大长度.默认为32.文件名一直全部输出. 
    -u username 
    以username的UID和GID执行被跟踪的命令.
``` 

