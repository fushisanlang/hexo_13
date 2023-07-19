---
title: rhel7基于ngx_http_auth_basic_module配置网站密码认证
date: 2019-12-5
updated: 2019-12-6
tags:
  - nginx
  - ngx_http_auth_basic_module
categories:
  - note
abbrlink: a57a4a11
---

## rhel7基于ngx_http_auth_basic_module配置网站密码认证

* 环境介绍

软件|版本|安装方法
-|-|-
系统|rhel7.4 64位| N/A
nginx|1.12.2|yum
httpd-tools|2.4.6-89|yum

* 语法


模块ngx_http_auth_basic_module 允许使用“HTTP基本认证”协议验证用户名和密码来限制对资源的访问。

也可以通过 地址来限制访问。 使用satisfy 指令就能同时通过地址和密码来限制访问。

* 配置范例

```nginx
location / {
    auth_basic           "closed site";
    auth_basic_user_file conf/htpasswd;
}
```
* 指令

语法:	`auth_basic string | off;`
默认值:	`auth_basic off;`
上下文:	`http, server, location, limit_except`
开启使用“HTTP基本认证”协议的用户名密码验证。 指定的参数被用作 域。 参数off可以取消继承自上一个配置等级 auth_basic 指令的影响。

语法:	`auth_basic_user_file file;`
默认值:	`—`
上下文:	`http, server, location, limit_except`
指定保存用户名和密码的文件，格式如下：

 ```nginx
# comment
name1:password1
name2:password2:comment
name3:password3
密码应该使用crypt()函数加密。 可以用Apache发行包中的htpasswd命令来创建此类文件。
 ```

* htpasswd命令

  * 安装
    ```shell
    yum install httpd-tools
    ```
  * 生成密码文件
    ```shell
    htpasswd -cb /etc/nginx/conf.d/passwd $name $pass
    ```
