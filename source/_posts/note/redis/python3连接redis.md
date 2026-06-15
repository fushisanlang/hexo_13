---
title: python3连接redis
date: 2026-06-15
tags:
  - python
  - redis
  - django
  - 缓存
categories:
  - note
---

## 基本使用

### 普通连接

```python
import redis

conn = redis.Redis(host="192.168.23.166", port=6379, password="123456")
conn.set("x1", "hello", ex=5)  # ex代表秒，px代表毫秒
val = conn.get("x1")
print(val)
```

### 连接池

```python
import redis

pool = redis.ConnectionPool(host="192.168.23.166", port=6379,
                           password="123456", max_connections=1024)
conn = redis.Redis(connection_pool=pool)
print(conn.get("x1"))
```

### Django全局配置

```python
# settings.py
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://127.0.0.1:6379",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "CONNECTION_POOL_KWARGS": {"max_connections": 100}
        }
    }
}
```

## 缓存级别

### 全栈缓存

在 settings.py 配置文件中添加：

```python
MIDDLEWARE = [
    'django.middleware.cache.UpdateCacheMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'django.middleware.cache.FetchFromCacheMiddleware',
]
```

`UpdateCacheMiddleware` 位于列表第一位，`FetchFromCacheMiddleware` 位于列表最末。

### 视图缓存

```python
from django.views.decorators.cache import cache_page

@cache_page(60 * 15)
def index(request):
    return HttpResponse("ok")
# 缓存15分钟
```

### 元素缓存

```html
{% load cache %}
{% cache 5000 缓存key %}
    缓存内容
{% endcache %}
```

## 基本操作

```python
redis.hget
redis.hgetall
redis.hincrby("k2", "age", amount=num)  # num为正数或负数
redis.hincrbyfloat

# 如果有大量数据，使用 scan 迭代
hscan_iter("k4", count=100)
```

> redis 操作对象时，只有第一层 value 支持 list、dict……
