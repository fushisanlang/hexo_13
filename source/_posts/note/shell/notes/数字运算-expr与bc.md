---
title: 数字运算-expr与bc
date: 2018-4-24
updated: 2018-4-25
tags:
  - shell
categories:
  - note
abbrlink: 736bae7c
---

###  数字运算-expr与bc

* expr基本语法
|        |           语法            |
| :----: | :-----------------------: |
| 方法一 | expr $num1 operator $num2 |
| 方法二 | $(($num1 operator $num2)) |



* expr操作符对照表

|   操作符   | 含义 |
| :--------: | :--: |
| num1\|num2 |num1不为空且非0，返回num1;否则返回num2      |
|num1 & num2 |num1不为空且非0，返回num1;否则返回0|
|num1 < num2 |num1小于num2，返回1;否则返回0|
|num1 <= num2 | num1小于等于num2，返回1;否则返回0|
|num1 = num2 | num1等于num2，返回1;否则返回0|
|num1 != num2 | num1不等于num2，返回1;否则返回0|
|num1 > num2 | num1大于num2，返回1;否则返回0|
|num1 >= num2 | num1大于等于num2，返回1;否则返回0|
|num1 + num2 | 求和|
|num1 - num2 | 求差|
|num1 * num2 | 求积|
|num1 / num2 | 求商|
|num1 % num2 | 求余|

<!--more-->
```shell
shell > expr 1 \| 2  #注意特殊符号需要转义，并且运算符前后要有空格
1 
shell > expr 0 \| 2
2
shell > expr 1 \& 2
1
shell > expr 0 \& 2
0
shell > expr 0 \< 2
1
shell > expr 0 \!= 2
1
shell > expr 0 + 2
2
shell > expr 3 % 2
1
```



* bc介绍

  * bc是bash内建的运算器，支持浮点数运算。expr不支持浮点数运算。
  * 内建变量scale可以设置，默认是0。

  * 可以加减乘除，取余，方法与expr相同。
  * 可以通过 `num1 ^ num2` 进行指数运算。

```shell
shell > bc
bc 1.06.95
Copyright 1991-1994, 1997, 1998, 2000, 2004, 2006 Free Software Foundation, Inc.
This is free software with ABSOLUTELY NO WARRANTY.
For details type `warranty'. 
2/3
0
scale=2
2/3
.66
^C
(interrupt) Exiting bc.

shell > echo "2/3" | bc
0
shell > echo "scale=3;2/3" | bc
.666
```

