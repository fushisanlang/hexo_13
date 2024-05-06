---
title: sed小技巧
tags:
  - sed
  - shell
categories:
  - note
abbrlink: 938a79eb
date: 2024-04-29 00:00:00
---


## 根据某个关键字替换指定范围内的字符
源文件：
```
line 1
line 2
line 3
```

替换命令：
```shell
sed '/line 2/{n;s/.*/new line/;}' example.txt
```

结果：
```shell
line 1
line 2
new line
```

原理：
* `/line 2/` 是一个地址，它指定了匹配模式。在这个例子中，`line 2` 是要匹配的模式。
* `{}` 中的内容是操作的范围。`n` 命令用于读取下一行，`s/.*/new line/` 命令用于将下一行替换为 `new line`

用途：   
可以通过这个替换json文件中的key。
源文件如下：

```json
[
    {
        "username":"test1",
        "passwd":""
    },
    {
        "username":"test2",
        "passwd":""
    },
]

```

命令示例如下：
```shell
      sed -i "/test2/{n;s/\"\"/\"$passwd\"/;}" config.json
```

通过这个命令就能替换test2的密码而不替换test1的密码。