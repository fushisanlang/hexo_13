---
title: spring cloud微服务日志跟踪 sleuth logback elk整合
date: 2026-06-15
tags:
  - springcloud
  - sleuth
  - logback
  - elk
  - 日志
  - 链路追踪
categories:
  - note
---

Spring Cloud 微服务日志跟踪，将服务之间的调用使用唯一标识串联起来，通过一个标识可以查看所有跨服务调用的串联日志。

<!--more-->

## Sleuth 原理

在最初发起调用者的时候在请求头 head 中添加唯一标识，传递到直接调用的服务上，之后的服务做类似的操作。

## 依赖引入

所有服务或 Spring Boot 项目都引入以下包：

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
<dependency>
    <groupId>com.cwbase</groupId>
    <artifactId>logback-redis-appender</artifactId>
    <version>1.1.5</version>
</dependency>
```

一个是传输 Redis 使用，一个是调用链跟踪使用。

## logback 配置

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration debug="false" scan="true" scanPeriod="1 seconds">
    <include resource="org/springframework/boot/logging/logback/base.xml" />
    <contextName>logback</contextName>

    <property name="log.path" value="\logs\logback.log" />
    <property name="log.pattern"
        value="%d{yyyy-MM-dd HH:mm:ss.SSS} -%5p ${PID} --- traceId:[%X{mdc_trace_id}] [%15.15t] %-40.40logger{39} : %m%n" />

    <!-- 文件 Appender -->
    <appender name="file" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${log.path}</file>
        <encoder>
            <pattern>${log.pattern}</pattern>
        </encoder>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>info-%d{yyyy-MM-dd}-%i.log</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy
                class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>10MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
            <maxHistory>10</maxHistory>
        </rollingPolicy>
    </appender>

    <!-- Redis Appender -->
    <appender name="redis" class="com.cwbase.logback.RedisAppender">
        <tags>test</tags>
        <host>IP</host>
        <port>6379</port>
        <key>test</key>
        <callerStackIndex>0</callerStackIndex>
        <location>true</location>
        <additionalField>
            <key>X-B3-ParentSpanId</key>
            <value>@{X-B3-ParentSpanId}</value>
        </additionalField>
        <additionalField>
            <key>X-B3-SpanId</key>
            <value>@{X-B3-SpanId}</value>
        </additionalField>
        <additionalField>
            <key>X-B3-TraceId</key>
            <value>@{X-B3-TraceId}</value>
        </additionalField>
    </appender>

    <root level="info">
        <appender-ref ref="redis" />
    </root>
</configuration>
```

## 关键字段说明

- **X-B3-TraceId**：整个调用链的唯一 ID，贯穿整个请求链路
- **X-B3-SpanId**：当前操作的 ID
- **X-B3-ParentSpanId**：父操作的 ID

## 与 ELK 串联

将日志输出到 Logstash（通过 Redis 或直接 TCP），再由 Logstash 传输到 ElasticSearch，在 Kibana 中可以通过 traceId 搜索整个调用链的日志。

> 配合 Logstash 的 `MDC`（Mapped Diagnostic Context）可以实现更详细的字段传递。
