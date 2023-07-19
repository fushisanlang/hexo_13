---
title: nginx location 配置及匹配规则
date: 2019-5-27
updated: 2019-5-28
tags:
  - nginx
  - location
categories:
  - note
abbrlink: b7352f98
---
# nginx location 配置及匹配规则

### 1.location 介绍

> location 是在 server 块中配置，用来通过匹配接收的uri来实现分类处理不同的请求，如反向代理，取静态文件等
> location 在 server 块中可以有多个，他们不是按匹配顺序不是按localtion的先后顺序排序，而是按规则的优先级
> localtion 匹配功能只做匹配分发用，并不会改变uri的内容或其他作用，我一开始理解的时候就混淆了一些概念，建议多做测试看实际效果

### 2.localtion 匹配规则

#### 规则概览：

```shell
location [ = | ~ | ~* | ^~ ] uri { … }
location @name { … }
```
#### 优先级：

```shell

(location =) > (location 完整路径) > (location ^~ 路径) > (location ,* 正则顺序) > (location 部分起始路径) > (/)
注1：规则不能混合使用
注2：以下例子说明都以该server为基础

 server {
        listen       8861;
        server_name  abc.com;
    }
```





#### 2.1 “=” 精确匹配
```shell
内容要同表达式完全一致才匹配成功
例：
location = / {
   .....
}
# 只匹配http://abc.com
#  http://abc.com [匹配成功]
#  http://abc.com/index [匹配失败]
```


#### 2.2 “~”，大小写敏感

```shell
location ~ /Example/ {
   .....
}

#http://abc.com/Example/  [匹配成功]
#http://abc.com/example/  [匹配失败]
```

#### 2.3.“~*”，大小写忽略

```shell
location ~* /Example/ {
   .....
}
# 则会忽略 uri 部分的大小写
#http://abc.com/test/Example/  [匹配成功]
#http://abc.com/example/  [匹配成功]
```

#### 2.4.“^~”，只匹配以 uri 开头

```shell
location ^~ /index/ {
   .....
}
#以 /img/ 开头的请求，都会匹配上
#http://abc.com/index/index.page   [匹配成功]
#http://abc.com/error/error.page [匹配失败]
```

#### 2.5.“@”，nginx内部跳转

```shell
location /index/ {
    error_page 404 @index_error;
}

location @index_error {
   .....
}
#以 /index/ 开头的请求，如果链接的状态为 404。则会匹配到 @index_error 这条规则上。 
```

#### 2.6 不加任何规则
```shell
默认是大小写敏感，前缀匹配，相当于加了“”与“^”
只有 / 表示匹配所有uri

location /index/ {
    ......
}

#http://abc.com/index   [匹配成功]
#http://abc.com/index/index.page   [匹配成功]
#http://abc.com/test/index   [匹配失败]
#http://abc.com/Index   [匹配失败]

# 匹配到所有uri
location / {
    ......
}
```
