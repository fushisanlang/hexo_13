---
title: awk
date: 2019-8-11
updated: 2019-8-12
tags:
  - awk
  - shell
categories:
  - note
abbrlink: c4a2fe4
---

###  awk

* awk

> awk是一个文本处理工具，通常用于处理数据并生成结果报告。

* 语法形式

`awk 'BEGIN{}pattern{command}END{}' `

|                语法项             |                       说明                        |
| :-----------------------------------------------: | :-----------------------------------------------: |
|  BEGIN{}        |           正式处理之前执行           |
| pattern | 匹配模式 |
|       command       |           处理命令，可能多行           |
| END{} | 处理完所有匹配数据后执行 |


* awk的内置变量

|                 变量                  |                       含义                        |
| :-----------------------------------------------: | :-----------------------------------------------: |
|  $0  |           只打印匹配行            |
|       -e       |           直接在命令行进行sed编辑，默认选项           |
|       -f       | 编辑动作保存在文件中，指定文件执行 |
|       -r       |           支持拓展正则表达式           |
|       -i       |           直接修改文件内容           |
<!--more-->
* pattern用法表

|                 匹配模式                |                       含义                        |
| :-----------------------------------------------: | :-----------------------------------------------: |
|  10command  |        匹配第10行        |
|       10,20command       |           匹配第10行开始，到第20行结束           |
|       10,+5command       | 匹配第10行开始，到第15行结束 |
|       /pattern1/command       |           匹配到pattern1的行           |
|       /pattern1/,/pattern2/command       |           匹配到pattern1的行开始，到匹配到pattern2行结束           |
|       10,/pattern1/command       |           匹配第10行开始，到匹配到pattern1行结束           |
|       /pattern1/,10command       |           匹配到pattern1的行开始，到第10行结束           |

```shell
shell > cat num
a1
b2
c3
d4
b5
e6
f7
g8
h9
i10
j11
k12
l13
m14
n15
o16
p17
q18
r19
s20
shell > sed -n '10p' num
i10
shell > sed -n '10,13p' num
i10
j11
k12
l13
shell > sed -n '10,+5p' num
i10
j11
k12
l13
m14
n15
shell > sed -n '/a/p' num
a1
shell > sed -n '/a/,/c/p' num 
a1
b2
c3
shell > sed -n '4,/f/p' num
d4
b5
e6
f7
shell > sed -n '/f/,9p' num
f7
g8
h9
```

* sed 编辑命令对照表


|              类别             |                       编辑命令                      | 含义|
| :-----------------------------------------------: | :-----------------------------------------------: |:-:|
| 查询 | p | 打印 |
|         查询         |           =           | 查询行号 |
|       增加       |           a          | 行后增加 |
|       增加       |          i          | 行前增加|
|       增加       |          r          | 外部文件读入，行后追加 |
|       增加       |           w          | 匹配行写入外部文件 |
|       删除       |           d          | 删除 |
|       修改       |  s/old/new/     | 行内第一个old替换为new |
|       修改       |  s/old/new/g       | 将行内所有old替换为new |
|       修改       |  s/old/new/2g       | 将行内从第二个开始到最后的old替换为new |
|       修改       |  s/old/new/2       | 将行内从第二个old替换为new |
|       修改       |  s/old/new/ig      | 将行内所有old替换为new，忽略大小写 |

```shell
shell > cat str.base 
i love linux and you LOVE liux too 
i love love love love love you
i like linux 
################
shell > cp -f str.base str.txt ; sed -n '/love/p' str.txt
i love linux and you LOVE liux too 
i love love love love love you
shell > cp -f str.base str.txt ; sed -n '/love/=' str.txt
1
2
################
shell > cp -f str.base str.txt ; sed -i '/love/i1' str.txt ; cat str.txt 
1
i love linux and you LOVE liux too 
1
i love love love love love you
i like linux 
shell > cp -f str.base str.txt ; sed -i '/love/a1' str.txt ; cat str.txt 
i love linux and you LOVE liux too 
1
i love love love love love you
1
i like linux 
shell > cat add.txt 
aaa
shell > cp -f str.base str.txt ; sed -i '/love/radd.txt' str.txt ; cat str.txt 
i love linux and you LOVE liux too 
aaa
i love love love love love you
aaa
i like linux 
shell > cp -f str.base str.txt ; sed -i '/love/wnew.txt' str.txt ; cat new.txt 
i love linux and you LOVE liux too 
i love love love love love you
################
shell > cp -f str.base str.txt ; sed -i '/love/d' str.txt ; cat str.txt 
i like linux 
################
shell > sed  's/love/ai/' str.base 
i ai linux and you LOVE liux too 
i ai love love love love you
i like linux 
shell > sed  's/love/ai/g' str.base 
i ai linux and you LOVE liux too 
i ai ai ai ai ai you
i like linux 
shell > sed  's/love/ai/2g' str.base 
i love linux and you LOVE liux too 
i love ai ai ai ai you
i like linux 
shell > sed  's/love/ai/2' str.base 
i love linux and you LOVE liux too 
i love ai love love love you
i like linux 
shell > sed  's/love/ai/ig' str.base 
i ai linux and you ai liux too 
i ai ai ai ai ai you
i like linux 
```

* 反向引用

`& ` 和 `\1` 可以引用模式匹配到的整个串

```shell
shell > sed -i 's/love/&s/g' str.base ; cat str.base
i loves linux and you LOVE liux too 
i loves loves loves loves loves you
i like linux 

#&可以引用匹配到的整个串
shell > sed -i  's/l...s/&AAA/g' str.base ; cat str.base  
i lovesAAA linux and you LOVE linux too 
i lovesAAA lovesAAA lovesAAA lovesAAA lovesAAA you
i like linux 

 #\1可以引用整个串，也可以引用部分。所有需要反向引用的部分，需要使用\(\)扩起来。
shell > sed -i  's/\(l...s\)AAA/\1BBB/g' str.base ; cat str.base
i lovesBBB linux and you LOVE linux too 
i lovesBBB lovesBBB lovesBBB lovesBBB lovesBBB you
i like linux 
shell > 

```

