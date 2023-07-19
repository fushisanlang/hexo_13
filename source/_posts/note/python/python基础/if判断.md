---
title: if 判断
date: 2017-1-12
updated: 2017-1-13
tags:
  - python
categories:
  - note
abbrlink: e8f5121a
---

## if 判断

```python
if <条件判断1>:
    <执行1>
elif <条件判断2>:
    <执行2>
elif <条件判断3>:
    <执行3>
else:
    <执行4>
```

`elif` 是`else if` 的简写，理论上可以有多个`elif` 。

`if` 语句是由上而下进行判断的，在遇见`True` 之后，判断就会中止，不再进行之后的判断。

示例如下：

```python
zhang=1
if zhang==0:
  print('0')
elif zhang==2:
  print('2')
elif zhang==3:
  print('3')
elif zhang==1:
  print('1')
else:
  print('13')
```
```shell
[python@fushisanlang liaoxuefeng_note]$ python3 test.py 
1
[python@fushisanlang liaoxuefeng_note]$ 
```

