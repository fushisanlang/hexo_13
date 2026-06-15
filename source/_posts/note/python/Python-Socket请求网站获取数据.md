---
title: Python Socket请求网站获取数据
date: 2026-06-15
tags:
  - python
  - socket
  - 网络编程
  - IO多路复用
categories:
  - note
---

几种 IO 模型对比：

- **阻塞 I/O** -> 收快递，快递如果不到，就干不了其他的活
- **非阻塞 I/O** -> 收快递，不断的去问，有没有送到……如果送到了就接收
- **I/O多路复用** -> 找个代理人(select)去收快递，快递到了就通知用户

<!--more-->

## 阻塞方式

blocking IO 会一直 block 对应的进程，直到操作完成。

```python
import socket
import time

ACCESS_URL = 'www.baidu.com'
ACCESS_PORT = 80

def blocking(pn):
    sock = socket.socket()
    sock.connect((ACCESS_URL, ACCESS_PORT))
    request_url = 'GET {} HTTP/1.0\r\nHost: www.baidu.com\r\n\r\n'.format('/s?wd={}'.format(pn))
    sock.send(request_url.encode())
    response = b''
    chunk = sock.recv(1024)
    while chunk:
        response += chunk
        chunk = sock.recv(1024)
    return response

def block_way():
    for i in range(5):
        blocking(i)

if __name__ == '__main__':
    start = time.time()
    block_way()
    print('请求5次页面耗时{}'.format(time.time() - start))
    # 请求5次页面耗时2.4048924446105957
```

## 非阻塞方式

non-blocking 在 kernel 还没准备好数据的情况下，会立即返回（会抛出异常）。

```python
import socket
import time

ACCESS_URL = 'www.baidu.com'
ACCESS_PORT = 80

def blocking(pn):
    sock = socket.socket()
    sock.setblocking(False)  # 设置为非阻塞
    try:
        sock.connect((ACCESS_URL, ACCESS_PORT))
    except BlockingIOError:
        pass
    request_url = 'GET {} HTTP/1.0\r\nHost: www.baidu.com\r\n\r\n'.format('/s?wd={}'.format(pn))
    while True:
        try:
            sock.send(request_url.encode())
            break
        except OSError:
            pass
    response = b''
    while True:
        try:
            chunk = sock.recv(1024)
            while chunk:
                response += chunk
                chunk = sock.recv(1024)
            break
        except BlockingIOError:
            pass
    return response
```

> 时间消耗在不断的 while 循环中，和阻塞的时间差不多

## 多线程方式

```python
import socket
from multiprocessing.pool import ThreadPool
import time

ACCESS_URL = 'www.baidu.com'
ACCESS_PORT = 80

def blocking(pn):
    sock = socket.socket()
    sock.connect((ACCESS_URL, ACCESS_PORT))
    request_url = 'GET {} HTTP/1.0\r\nHost: www.baidu.com\r\n\r\n'.format('/s?wd={}'.format(pn))
    sock.send(request_url.encode())
    response = b''
    chunk = sock.recv(1024)
    while chunk:
        response += chunk
        chunk = sock.recv(1024)
    return response

def block_way():
    pool = ThreadPool(5)
    for i in range(10):
        pool.apply_async(blocking, args=(i,))
    pool.close()
    pool.join()

if __name__ == '__main__':
    start = time.time()
    block_way()
    print('请求10次页面耗时{}'.format(time.time() - start))
    # 请求10次页面耗时1.1231656074523926
```

## 多进程方式

```python
from multiprocessing import Pool

def block_way():
    pool = Pool(5)
    for i in range(10):
        pool.apply_async(blocking, args=(i,))
    pool.close()
    pool.join()

# 请求10次页面耗时1.1685676574707031
# 略慢于线程池实现方式，因为进程相对于线程开销比较大
```

## 协程方式

```python
import socket
import gevent
from gevent import monkey
monkey.patch_all()
from gevent.pool import Pool

ACCESS_URL = 'www.baidu.com'
ACCESS_PORT = 80

def blocking(pn):
    sock = socket.socket()
    sock.connect((ACCESS_URL, ACCESS_PORT))
    request_url = 'GET {} HTTP/1.0\r\nHost: www.baidu.com\r\n\r\n'.format('/s?wd={}'.format(pn))
    sock.send(request_url.encode())
    response = b''
    chunk = sock.recv(1024)
    while chunk:
        response += chunk
        chunk = sock.recv(1024)
    return response

def block_way():
    pool = Pool(5)
    pool.map(blocking, range(10))

# 请求10次页面耗时0.5716912746429443
```

## IO多路复用

### select

```python
import socket
import select

ACCESS_URL = 'www.baidu.com'
ACCESS_PORT = 80

def select_way(urls):
    socks = []
    for i, url in enumerate(urls):
        sock = socket.socket()
        sock.setblocking(False)
        try:
            sock.connect((ACCESS_URL, ACCESS_PORT))
        except BlockingIOError:
            pass
        request_url = 'GET {} HTTP/1.0\r\nHost: www.baidu.com\r\n\r\n'.format('/s?wd={}'.format(i))
        sock.url = url
        sock.send(request_url.encode())
        socks.append(sock)

    result = {}
    while len(socks):
        r, w, e = select.select(socks, [], [])
        for s in r:
            chunk = s.recv(1024)
            if not chunk:
                result[s.url] = 'done'
                socks.remove(s)
                continue
            result[s.url] = chunk

# 适用于大量连接但实际通信不多的场景
```
