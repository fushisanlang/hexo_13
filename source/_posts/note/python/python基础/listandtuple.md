---
title: list and tuple
date: 2016-3-6
updated: 2016-3-7
tags:
  - python
categories:
  - note
abbrlink: aa7943f3
---
## list and tuple

### list 列表

```python
>>> zhangyin = [ zhang , yin ]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'zhang' is not defined
>>> zhangyin=[zhang,yin]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'zhang' is not defined
>>> zhangyin = [zhang,yin]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'zhang' is not defined
>>> zhangyin = ['zhang' , 'yin' ]
>>>     
#之前定义列表出错是因为直接使用zhang这个变量，但是之前并未定义这个变量。因为使用时，是想直接使用字符串'zhang'，所以最后一次定义时，在字符串两端增加了引号。最终定义成功。此时，变量zhangyin就是一个列表。

>>> len(zhangyin)
2
>>>   
#len方法用于获得列表中元素个数。

>>> zhangyin[0]
'zhang'
>>> zhangyin[1]
'yin'
>>> zhangyin[2]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
IndexError: list index out of range
>>> 
#在列表以及元组中，第一个元素索引是0，而不是1。相对的，最后一个元素索引是列表或元组长度减一。在实例中，字符串'zhang'索引是0，'yin'的索引是1。

>>> zhangyin[-1]
'yin'
>>> 
#也可以反向取值，此时最后一个元素索引为-1，以此类推，-len(zhangyin)也可以表示列表中的第一个元素。

>>> zhangyin
['zhang', 'yin']
>>> zhangyin.append(13)
>>> zhangyin
['zhang', 'yin', 13]
>>> zhangyin.insert(1,'fushishanlang')
>>> zhangyin
['zhang', 'fushishanlang', 'yin', 13]
>>> zhangyin.pop()
13
>>> zhangyin
['zhang', 'fushishanlang', 'yin']
>>> zhangyin.pop(1)
'fushishanlang'
>>> zhangyin
['zhang', 'yin']
>>> zhangyin[1]='YIN'
>>> zhangyin
['zhang', 'YIN']
>>> 
#通过append方法向列表追加元素，也可以通过insert方法将元素添加到指定位置。
#通过pop方法删除列表中最后一个元素，也可以通过pop(*)的方式，按照索引删除相应的元素。*代表元素的索引。
#通过直接赋值的方法，可以修改元素。

#元素可以是字符串，布尔值，浮点数，也可以是另一个列表。

```
<!--more-->
### tuple 元组

```python
>>> zhangyin=('zhang','yin')
>>> zhangyin
('zhang', 'yin')
>>> zhangyin=()
>>> zhangyin
()
>>> zhangyin=('zhang')
>>> zhangyin
'zhang'
>>> zhangyin=('zhang',)
>>> zhangyin
('zhang',)
>>> 
#元组与列表类似，但是一旦初始化后就不能修改。
#可以定义一个空的元组。
#但是定义单一元素元组时，需要加上一个逗号。因为小括号也有可能会表示一个运算中的括号，所以需要一个逗号消除歧义。同样的，系统在返回一个单元素数组时，也会有逗号。
```

