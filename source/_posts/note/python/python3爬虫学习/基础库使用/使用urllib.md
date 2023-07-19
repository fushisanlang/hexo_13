---
title: urllib
date: 2019-2-20
updated: 2019-2-21
tags:
  - python
  - 爬虫
  - urllib
categories:
  - note
abbrlink: 4e81241b
---

# 使用urllib



### 简介

* 在python2中，有urllib和urllib2两个库。在python3中，统一为urllib。
* 他是python内置的http请求库，无需额外安装即可使用。
* 包含如下四个模块
  * request：最基本的HTTP请求模块，用来模拟发送请求，只需要传入url以及额外的参数。
  * error：异常处理模块，如果出现请求错误，我们可以捕获这些异常，然后进行重试或其他操作以保证程序不会意外终止。
  * parse：一个工具模块，提供了许多URL处理方法。
  * robotparser：用来识别网站的robots.txt文件，判断网站是否可以爬。



### 发送请求

1. urlopen()

urllib.request模块提供了最基本的构造http请求的方法，利用他可以模拟浏览器的请求发起过程，同时他还带有授权验证、重定向、浏览西cookies以及其他内容。

以百度为例：

```python
import urllib.request

response = urllib.request.urlopen('https://baidu.com')
print(response.read().decode('utf-8'))
```

运行上述代码，就会完成对百度首页的抓取，输出网页的源代码。

接下来，利用type()方法输出相应的类型：
<!--more-->
```python
import urllib.request

response = urllib.request.urlopen('https://baidu.com')
print(type(response))
```
运行上述代码输出结果如下：
```shell
[python@localhost python3webspider]$ python3 urlopen.py
<class 'http.client.HTTPResponse'>
```

可以发现，他是一个HTTPResposne类型的对象，得到这个对象后，我们把他赋值为response变量，然后就可以调用相应的方法属性得到结果的一系列信息。

例如，调用read()方法可以得到返回的网页内容，调用status属性可以得到返回结果的状态码。示例如下：

```python
import urllib.request
 
response = urllib.request.urlopen('https://baidu.com')
print(response.status)
print(response.getheaders())
print(response.getheader('Server'))                                                             
```

运行上述代码输出结果如下：

```shell
[python@localhost python3webspider]$ python3 urlopen.py
200
[('Bdpagetype', '1'), ('Bdqid', '0xd4cb8f3e000412de'), ('Cache-Control', 'private'), ('Content-Type', 'text/html'), ('Cxy_all', 'baidu+4762ec06d8ecda4e5726dd1f0275df33'), ('Date', 'Sun, 25 Nov 2018 05:58:11 GMT'), ('Expires', 'Sun, 25 Nov 2018 05:58:07 GMT'), ('P3p', 'CP=" OTI DSP COR IVA OUR IND COM "'), ('Server', 'BWS/1.1'), ('Set-Cookie', 'BAIDUID=3B091DC52784E6AE2AE89A9DD6B9370D:FG=1; expires=Thu, 31-Dec-37 23:55:55 GMT; max-age=2147483647; path=/; domain=.baidu.com'), ('Set-Cookie', 'BIDUPSID=3B091DC52784E6AE2AE89A9DD6B9370D; expires=Thu, 31-Dec-37 23:55:55 GMT; max-age=2147483647; path=/; domain=.baidu.com'), ('Set-Cookie', 'PSTM=1543125491; expires=Thu, 31-Dec-37 23:55:55 GMT; max-age=2147483647; path=/; domain=.baidu.com'), ('Set-Cookie', 'delPer=0; path=/; domain=.baidu.com'), ('Set-Cookie', 'BDSVRTM=0; path=/'), ('Set-Cookie', 'BD_HOME=0; path=/'), ('Set-Cookie', 'H_PS_PSSID=1466_21078_26350_20718; path=/; domain=.baidu.com'), ('Vary', 'Accept-Encoding'), ('X-Ua-Compatible', 'IE=Edge,chrome=1'), ('Connection', 'close'), ('Transfer-Encoding', 'chunked')]
BWS/1.1
```

### 传递参数

利用最基本的urlopen（）方法可以完成get请求，但是有时需要给连接传递一些参数。

urlopen()函数API如下：

```python
urllib.request.urlopen(url,data=None.[timeout,]*,cafile=None,capath=None,cadefaule=Flase,contest=None)
```

可以发现，除了第一个参数可以传递url之外，还可以传递data，timeout等参数。下面介绍这几个参数的用法：

* data参数

data参数是可选的，如果要增加该参数，需要使用bytes()方法将参数转换为字节流编码格式内容，即bytes类型。另外，如果传递了这个参数，那请求类型就不再是GET，而是POST。

示例如下：

```python
import urllib.parse
import urllib.request
 
data = bytes(urllib.parse.urlencode({'word': 'hello'}), encoding='utf8')
response = urllib.request.urlopen('http://httpbin.org/post',data=data)   
print(response.read())
```

运行示例如下：

```shell
[python@localhost python3webspider]$ python3 urlopen_data.py
b'{\n  "args": {}, \n  "data": "", \n  "files": {}, \n  "form": {\n    "word": "hello"\n  }, \n  "headers": {\n    "Accept-Encoding": "identity", \n    "Connection": "close", \n    "Content-Length": "10", \n    "Content-Type": "application/x-www-form-urlencoded", \n    "Host": "httpbin.org", \n    "User-Agent": "Python-urllib/3.6"\n  }, \n  "json": null, \n  "origin": "222.91.125.114", \n  "url": "http://httpbin.org/post"\n}\n'
[python@localhost python3webspider]$ python3 urlopen_data.py | sed 's/\\n/\n/g'
b'{
  "args": {}, 
  "data": "", 
  "files": {}, 
  "form": {
    "word": "hello"
  }, 
  "headers": {
    "Accept-Encoding": "identity", 
    "Connection": "close", 
    "Content-Length": "10", 
    "Content-Type": "application/x-www-form-urlencoded", 
    "Host": "httpbin.org", 
    "User-Agent": "Python-urllib/3.6"
  }, 
  "json": null, 
  "origin": "222.91.125.114", 
  "url": "http://httpbin.org/post"
}
'
```

这里我们传递了一个参数word，值是hello。他需要被转码成bytes类型。采用了bytes方法，该方法的第一个参数需要是str类型，需要用urllib.parse模块里的urlencode()方法将参数字典转化为字符串；第二个参数指定编码格式，这里指定为utf8.

请求的站点为httpbin.org，他提供HTTP请求测试。本地请求的url为http://httobin.org/post，这个链接可以用来测试post请求，他可以输出请求的信息，其中包括data参数。

我们传递的参数出现在了form字段中，说明模拟了表单提交的方式传递了数据。

* timeout参数

