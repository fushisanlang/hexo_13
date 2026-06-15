---
title: 使用psutil和MongoDB做系统监控
date: 2026-06-15
tags:
  - python
  - psutil
  - mongodb
  - 监控
  - bottle
categories:
  - note
---

使用 Python psutil 采集服务器数据，MongoDB 存储，bottle Web 框架，jqplot 图表展示。思路通用于任何数据库或 Web 框架。

<!--more-->

## 架构

- **psutil**：采集 CPU、内存、磁盘数据
- **MongoDB**：存储时序监控数据
- **bottle**：轻量 Web 服务
- **jqplot**：前端图表展示

## Part 1: 采集数据

```python
import psutil
import pymongo
from datetime import datetime
import socket

conn = pymongo.Connection('localhost', 27017)
db = conn['loadmonitor']

def get_server_data():
    cpu = psutil.cpu_times()
    phymem = psutil.virtual_memory()
    disk = psutil.disk_usage('/')

    doc = {
        'server': socket.gethostname(),
        'date': datetime.now(),
        'disk_root': disk.free,
        'phymem': phymem.free,
        'cpu': {
            'user': cpu.user,
            'nice': cpu.nice,
            'system': cpu.system,
            'idle': cpu.idle,
            'irq': cpu.irq
        }
    }
    db['example01'].save(doc)
```

## Part 2: Bottle Server

```python
from bottle import route, run, template

@route('/')
def index():
    return template('index')

@route('/load/<server>')
def get_loaddata(server):
    data_cursor = db[server].find()
    result = {
        'disk_root_free': [],
        'phymem_free': [],
        'cpu_user': [],
        'cpu_nice': [],
        'cpu_system': [],
        'cpu_idle': [],
        'cpu_irq': []
    }
    for data in data_cursor:
        date = data['date']
        result['disk_root_free'].append([date, data['disk_root']])
        result['phymem_free'].append([date, data['phymem']])
        result['cpu_user'].append([date, data['cpu']['user']])
        # ...
    return result

run(host='0.0.0.0', port=8080)
```

## Part 3: 前端 jqplot

```html
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Load Monitoring</title>
  <link rel="stylesheet" type="text/css" href="/css/jquery.jqplot.css" />
</head>
<body>
  <div id="cpu_user" style="height:400px;width:800px;"></div>

  <script src="http://code.jquery.com/jquery-latest.min.js"></script>
  <script src="/js/jquery.jqplot.js"></script>
  <script src="/js/jqplot.dateAxisRenderer.js"></script>
  <script>
    $(document).ready(function() {
      var jsonData = $.ajax({
        url: "http://example01/load/example01",
        dataType: "json"
      });

      $.jqplot('cpu_user', [jsonData.responseJSON['cpu_user']], {
        title: "CPU User Percent",
        axes: {
          xaxis: {
            renderer: $.jqplot.DateAxisRenderer,
            tickOptions: { formatString: "%a %H:%M" }
          }
        }
      });
    });
  </script>
</body>
</html>
```

## 采集脚本定时执行

```bash
# 每分钟采集一次
*/1 * * * * /usr/bin/python /path/to/monitor.py
```
