---
title: nginx root与alias的区别
date: 2016-8-8
updated: 2016-8-9
tags:
  - nginx
categories:
  - note
abbrlink: 90ea0300
---

# nginx root与alias的区别

nginx指定文件路径有两种方式root和alias，指令的使用方法和作用域：

```shell
[root]
语法：root path
默认值：root html
配置段：http、server、location、if

[alias]
语法：alias path
配置段：location
```
root与alias主要区别在于nginx如何解释location后面的uri，这会使两者分别以不同的方式将请求映射到服务器文件上。
root的处理结果是：root路径＋location路径
alias的处理结果是：使用alias路径替换location路径
alias是一个目录别名的定义，root则是最上层目录的定义。
还有一个重要的区别是alias后面必须要用“/”结束，否则会找不到文件。而root则可有可无。

root实例：
```
location ^~ /t/ {
     root /www/root/html/;
}

location ^~ /t/ {
     root /www/root/html/;
}
```
如果一个请求的URI是/t/a.html时，web服务器将会返回服务器上的/www/root/html/t/a.html的文件。

alias实例：
```
location ^~ /t/ {
 alias /www/root/html/new_t/;
}
```
如果一个请求的URI是/t/a.html时，web服务器将会返回服务器上的/www/root/html/new_t/a.html的文件。注意这里是new_t，因为alias会把location后面配置的路径丢弃掉，把当前匹配到的目录指向到指定的目录。

* 用alias时，目录名后面一定要加"/"。

* alias在使用正则匹配时，必须捕捉要匹配的内容并在指定的内容处使用。

* alias只能位于location块中。root可以不放在location中。
