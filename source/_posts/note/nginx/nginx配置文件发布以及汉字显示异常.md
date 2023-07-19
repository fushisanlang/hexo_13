---
title: nginx配置文件发布以及汉字显示异常
date: 2017-1-7
updated: 2017-1-8
tags:
  - nginx
categories:
  - note
abbrlink: e33da698
---

### nginx配置文件发布以及汉字显示异常



* nginx配置文件发布

```
    autoindex_exact_size off;
    autoindex_localtime on;
    autoindex on;

```

* nginx配置文件发布汉字显示异常

```
    default_type 'text/html';
    charset utf-8;
```



