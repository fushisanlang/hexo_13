---
title: Python与RabbitMQ交互
date: 2026-06-15
tags:
  - python
  - rabbitmq
  - 消息队列
categories:
  - note
---

## RabbitMQ 消息队列

成熟的中间件 RabbitMQ、ZeroMQ、ActiveMQ 等等。

RabbitMQ 使用 erlang 语言开发，使用 RabbitMQ 前要安装 erlang 语言。

RabbitMQ 允许不同应用、程序间交互数据。

python 中的 Threading queue 只能允许单进程内多线程交互的。python 中的 MultiProcessing queue 只能允许父进程与子进程或同父进程的多个子进程交互。

<!--more-->

## RabbitMQ启动

1. Windows 中默认安装成功，在服务列表中会显示自动启动
2. Linux 中使用命令 `rabbitmq-server start`

RabbitMQ 支持不同的语言，对于不同语言有相应的模块，这些模式支持使用开发语言连接 RabbitMQ。

Python 连接 RabbitMQ 模块有：

1. **pika** 主流模块
2. **Celery** 分布式消息队列
3. **Haigha** 提供了一个简单的使用客户端库来与 AMQP 代理进行交互的方法

使用 RabbitMQ 前，首先阅读开始文档：http://www.rabbitmq.com/getstarted.html

## 简单的发送接收实例

默认情况下，使用同一队列的进程，接收消息方使用轮询的方式，依次获取消息。

对于一条消息的接收来说，只有当接收方收到消息，并处理完消息，给 RabbitMQ 发送 ack，队列中的消息才会删除。

如果在处理的过程中 socket 断开，那么消息自动转接到下一个接收方。

### producer.py

```python
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()
channel.queue_declare(queue='hello')
channel.basic_publish(exchange='',
                      routing_key='hello',
                      body='Hello World!')
connection.close()
```

### consumer.py

```python
import pika, time

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()
channel.queue_declare(queue='hello')

def callback(ch, method, properties, body):
    print(f" [x] Received {body}")
    time.sleep(body.count(b'.'))
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_qos(prefetch_count=1)
channel.basic_consume(queue='hello', on_message_callback=callback)
print(' [*] Waiting for messages. To exit press CTRL+C')
channel.start_consuming()
```

## 在RabbitMQ中查看当前队列数

Windows 中查看队列，在 RabbitMQ 安装目录下，sbin 下有个管理工具 `rabbitmqctl.bat` 可以查看队列和队列中的消息数：

```bash
E:\RabbitMQ Server\rabbitmq_server-3.6.14\sbin>rabbitmqctl.bat list_queues
Listing queues
hello 1
```

## 消息持久化

如果当 RabbitMQ 服务器宕机了，不允许为处理的消息丢失时：

1. 需要在声明队列时，声明为持久队列，只是队列持久化，消息未能持久化

```python
channel.queue_declare(queue='hello', durable=True)
```

2. 需要在发送端发送消息时声明

```python
channel.basic_publish(exchange='',
                      routing_key='hello',
                      body='Hello World!',
                      properties=pika.BasicProperties(
                          delivery_mode=2,  # make message persistent
                      ))
```

## 消息处理配置

对于不同性能的机器，处理消息量大小不同。判断接收方消息队列里是否有未处理的消息，如果队列里还有1条消息未处理完，将不能接收新的消息：

```python
channel.basic_qos(prefetch_count=1)
```

## 发送广播消息

使用 exchange，exchange 的类型决定如果发送广播消息，它就是一个转发器。

类型：

- **fanout**: 所有 bind 到此 exchange 的 queue 都可以接收消息
- **direct**: 通过 routingKey 和 exchange 决定的那个唯一的 queue 可以接收消息
- **topic**: 所有符合 routingKey（此时可以是一个表达式）的 routingKey 所 bind 的 queue 可以接收消息
- **headers**: 通过 headers 来决定把消息发给哪些 queue

### fanout 纯广播

只要 bind 到 exchange 的 queue 都能收到广播消息。发送的消息只广播发送一次。

```python
channel.exchange_declare(exchange='log', type='fanout')
channel.basic_publish(exchange='log',
                      routing_key='',
                      body=message)
```

### fanout_producer.py

```python
import pika, sys

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()
channel.exchange_declare(exchange='log', type='fanout')
message = ' '.join(sys.argv[1:]) or 'info: Hello World!'
channel.basic_publish(exchange='log',
                      routing_key='',
                      body=message)
connection.close()
```

### fanout_consumer.py

```python
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()
channel.exchange_declare(exchange='log', type='fanout')
result = channel.queue_declare(exclusive=True)
queue_name = result.method.queue
channel.queue_bind(exchange='log', queue=queue_name)

def callback(ch, method, properties, body):
    print(f" [x] {body}")

channel.basic_consume(queue=queue_name, on_message_callback=callback)
print(' [*] Waiting for logs. To exit press CTRL+C')
channel.start_consuming()
```

### topic 过滤内容广播

队列只接收关心的消息。

### direct 路由

通过 routingKey 和 exchange 决定哪个 queue 可以接收消息。

```python
channel.exchange_declare(exchange='direct_logs', type='direct')
result = channel.queue_declare(exclusive=True)
queue_name = result.method.queue
severity = 'error'  # could be 'info', 'warning', 'error'
channel.queue_bind(exchange='direct_logs',
                   queue=queue_name,
                   routing_key=severity)
```
