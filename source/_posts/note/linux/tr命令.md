---
title: tr 命令权限列表
date: 2018-7-8
updated: 2018-7-9
tags:
  - tr
categories:
  - note
abbrlink: '97205115'
---

## tr 命令

> **tr命令**可以对来自标准输入的字符进行替换、压缩和删除。它可以将一组字符变成另一组字符，经常用来编写优美的单行命令，作用很强大。

```shell
-c或——complerment：取代所有不属于第一字符集的字符；
-d或——delete：删除所有属于第一字符集的字符；
-s或--squeeze-repeats：把连续重复的字符以单独一个字符表示；
-t或--truncate-set1：先删除第一字符集较第二字符集多出的字符。
```

<!--more-->
```shell
echo "HELLO WORLD" | tr 'A-Z' 'a-z'
hello world
```

```shell
echo "hello 123 world 456" | tr -d '0-9'
hello  world 
```

``` shell
cat text | tr '\t' ' '
```

``` shell
echo aa.,a 1 b#$bb 2 c*/cc 3 ddd 4 | tr -d -c '0-9 \n'
 1  2  3  4
```

```shell
echo "thissss is      a text linnnnnnne." | tr -s ' sn'
this is a text line.
```

```shell
echo 1 2 3 4 5 6 7 8 9 | xargs -n1 | echo $[ $(tr '\n' '+') 0 ]
```

```shell
cat file | tr -s "\r" "\n" > new_file
或
cat file | tr -d "\r" > new_file
```

```shell
[:alnum:]：字母和数字
[:alpha:]：字母
[:cntrl:]：控制（非打印）字符
[:digit:]：数字
[:graph:]：图形字符
[:lower:]：小写字母
[:print:]：可打印字符
[:punct:]：标点符号
[:space:]：空白字符
[:upper:]：大写字母
[:xdigit:]：十六进制字符
```

```shell
tr '[:lower:]' '[:upper:]'
```

