---
title: cdn
date: 2020-7-18
updated: 2020-7-19
tags:
  - cdn
categories:
  - note
abbrlink: 1e4b4e97
---

# 准备工作

**server1**

    yum install varnish-*
    #关闭selinux和iptables

**server2**
**server3**

    yum install -y httpd
    #编辑默认发布文件
    #关闭selinux和iptables

<!--more-->
# 单个缓存

    cd /etc/varnish/
    vim /etc/sysconfig/varnish #配置文件
        #66行 端口改为80
        
    vim default.vcl   
        8行 地址改为server2IP
        
    /etc/init.d/varnish start   #启动服务
    
    vim default.vcl  #在第10行』之后
        sub vcl_deliver {
            if (obj.hits > 0) {
                set resp.http.X-Cache = "HIT from westos cache";
            }
            else {
                set resp.http.X-Cache = "MISS from westos cache";
            }
            return (deliver);
        }

    /etc/init.d/varnish reload


# 多缓存

在配置文件中添加，并将上一部分中的default改为web1

        backend web2 {
            .host = "172.25.15.3";
            .port = "80";
        }


        sub vcl_recv {
            if (req.http.host ~ "^(www.)?server2.westos.com") {
                set req.http.host = "server2.westos.com";
                set req.backend = web1;
            } 
            elsif (req.http.host ~ "^server3.westos.com") {
                set req.backend = web2;
            } 
            else {error 404 "westos cache";
            }
        }
        #文件中的域名应该与主机中的解析保持一致

**本地**  
    
    vim /etc/hosts
        172.25.15.1 server1
        172.25.15.1 server1.westos.com
        172.25.15.1 server2.westos.com
        172.25.15.1 server3.westos.com

# 冗余 

**预期目的**

在server3上建立虚拟主机 访问server2.westos.com时，分别访问server2和server3，以增加server3的利用率，降低server2的压力


**server3**

    vim /etc/httpd/conf/httpd.conf 
        #990行 去掉注释
        #最末尾添加
        <VirtualHost *:80>
            DocumentRoot /var/www/html
            ServerName server3.westos.com
        </VirtualHost>
        <VirtualHost *:80>
            DocumentRoot /server2
            ServerName server2.westos.com
        </VirtualHost>

    /etc/init.d/httpd restart

    mkdir /server2
    vim /server2/index.html 
	    server2 on server3

**server1**

    vim /etc/sysconfig/varnish 
        #加入 	
        #director test round-robin {
            {.backend = web1;}
            {.backend = web2;}
        }    #test 为组件名字 可以更改 但是要与下文相符

	#将多缓存中server2的backend改为test

    /etc/init.d/varnish reload

此时通过主机进行验证。
如果主机访问server2是发布文件内容没有变化，可能是因为server1上已经有缓存。
可以通过varnishadm ban.url .*$ 在server1上清空缓存。
或者直接在varnish的配置文件中
在
        
        set req.backend = test;
语句的下一行，键入

        return (pass);
表示在访问server2.westos.com时，不进行缓存，直接从后台服务器拿取数据。


# cdn推送管理

**预期目的**

当网站后台发生改变通过推送管理使cdn中的缓存过期。   
*注意，是使缓存过期，而不是把改编后的页面推送到cdn中*

**server3**

改变server2.westos.com的默认发布文件，以方便查看

**server1** 

    yum install -y httpd
    vim /etc/httpd/conf/httpd.conf 
        #把监听端口由80改为8080
        #把bansys.zip文件解压到http默认发布目录
    cd /var/www/html
    vim config.php
        <?php
            //varnish主机列表
            //可定义多个主机列表
            $var_group1 = array(
                'host' => array('172.25.15.1'),
                'port' => '6082',
            );
            //varnish群组定义
            //对主机列表进行绑定
            $VAR_CLUSTER = array(
                'server2.westos.com' => $var_group1,        
                #在此处设置了要设置推送的网址
                #此处设置的为server2.westos.com
                #如有多个网址，可以直接添加。
                #但是要注意，如果缓存服务不同，要在前面添加新的群组
            );
            //varnish版本
            //2.x和3.x推送命令不一样
            $VAR_VERSION = "3";
        ?>
            
    cd /etc/varnish/
            
    vim default.vcl
        #在文件最开始
        acl westos {
            "127.0.0.1";
            "172.25.15.0"/24;
        }
        #在vcl_recv 命令块的最后一个大括号之前
        if (req.request == "BAN") {
            if (!client.ip ~ westos) {
                error 405 "Not allowed.";
                }
            ban("req.url ~ " + req.url);
            error 200 "ban added";
        }


    #如果之前实验使用了return（pass） 应删掉
    /etc/init.d/varnish reload
    /etc/init.d/httpd start


通过在主机的浏览器中访问172.25.15.1：8080 进入推送管理界面   
在管理界面中，选择http方式   
然后通过输入改变页面的位置，来推送管理   
如之前更改了server2.westos.com的发布文件，就可以输入   
http://server2.wesetos.com/index.html   
或直接输入   
/index.html   
来推送管理。


在另外界面通过访问server2.westos.com/index.html观察变化。






