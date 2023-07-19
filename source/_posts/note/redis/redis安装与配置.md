---
title: redis安装与配置
date: 2016-1-13
updated: 2016-1-14
tags:
  - redis
categories:
  - note
abbrlink: cd10e876
---


* 安装

通过官网下载源码tar.gz包。现在最新的版本是3.2.8。
将下载好的源码包放到家目录中，解压。
	
	tar zxf redis-3.2.8.tar.gz
	cd redis-3.2.8
	yum install gcc -y ###源码编译安装需要C语言编译器，所以需要安装gcc
	make
	make install
	./utils/install_server.sh   #自动配置 包括端口配置文件等等
	
<!--more-->
* 使用

通过源码安装的redis可以直接使用，也可以通过配置文件更改配置之后使用。
在安装之后，可以直接通过

	service redis_6379 start
脚本启动服务。redis的默认端口为6379端口。 

可以通过

	redis-cli
进入交互式界面进行操作。

*  配置   



redis的默认配置文件在。

	[root@localhost redis-3.2.8]# pwd
	/etc/redis 
	[root@localhost redis-3.2.8]# ll 6379.conf 
	-rw-rw-r--. 1 root root 46696 3月  31 00:54 6379.conf
这个6379.conf既是redis的默认配置文件。

可以通过vim编辑器进行编辑。

主要配置项：

      
	  
　●daemonize   
默认情况下，redis不是在后台运行的，如果需要在后台运行，把该项的值更改为yes。

●pidfile   
当Redis在后台运行的时候，Redis默认会把pid文件放在/var/run/redis.pid，你可以配置到其他地址。当运行多个redis服务时，需要指定不同的pid文件和端口。

●bind   
指定Redis只接收来自于该IP地址的请求，如果不进行设置，那么将处理所有请求，在生产环境中最好设置该项。   

●port   
监听端口，默认为6379。   

●timeout   
设置客户端连接时的超时时间，单位为秒。当客户端在这段时间内没有发出任何指令，那么关闭该连接。   

●loglevel   
log等级分为4级，debug, verbose, notice, 和warning。生产环境下一般开启notice。   

●logfile   
配置log文件地址，默认使用标准输出，即打印在命令行终端的窗口上。   

●databases   
设置数据库的个数，可以使用SELECT 命令来切换数据库。默认使用的数据库是0。   

●save   
设置Redis进行数据库镜像的频率。   
if(在60秒之内有10000个keys发生变化时){
进行镜像备份
}else if(在300秒之内有10个keys发生了变化){
进行镜像备份
}else if(在900秒之内有1个keys发生了变化){
进行镜像备份
}

●rdbcompression   
在进行镜像备份时，是否进行压缩。   

●dbfilename   
镜像备份文件的文件名。   

●dir   
数据库镜像备份的文件放置的路径。这里的路径跟文件名要分开配置是因为Redis在进行备份时，先会将当前数据库的状态写入到一个临时文件中，等备份完成时，再把该该临时文件替换为上面所指定的文件，而这里的临时文件和上面所配置的备份文件都会放在这个指定的路径当中。   

●slaveof   
设置该数据库为其他数据库的从数据库。   

●masterauth   
当主数据库连接需要密码验证时，在这里指定。   

●requirepass   
设置客户端连接后进行任何其他指定前需要使用的密码。警告：因为redis速度相当快，所以在一台比较好的服务器下，一个外部的用户可以在一秒钟进行150K次的密码尝试，这意味着你需要指定非常非常强大的密码来防止暴力破解。   

●maxclients   
限制同时连接的客户数量。当连接数超过这个值时，redis将不再接收其他连接请求，客户端尝试连接时将收到error信息。   

●maxmemory   
设置redis能够使用的最大内存。当内存满了的时候，如果还接收到set命令，redis将先尝试剔除设置过expire信息的key，而不管该key的过期时间还没有到达。在删除时，将按照过期时间进行删除，最早将要被过期的key将最先被删除。如果带有expire信息的key都删光了，那么将返回错误。这样，redis将不再接收写请求，只接收get请求。maxmemory的设置比较适合于把redis当作于类似memcached的缓存来使用。   

●appendonly   
默认情况下，redis会在后台异步的把数据库镜像备份到磁盘，但是该备份是非常耗时的，而且备份也不能很频繁，如果发生诸如拉闸限电、拔插头等状况，那么将造成比较大范围的数据丢失。所以redis提供了另外一种更加高效的数据库备份及灾难恢复方式。开启append only模式之后，redis会把所接收到的每一次写操作请求都追加到appendonly.aof文件中，当redis重新启动时，会从该文件恢复出之前的状态。但是这样会造成appendonly.aof文件过大，所以redis还支持了BGREWRITEAOF指令，对appendonly.aof进行重新整理。所以我认为推荐生产环境下的做法为关闭镜像，开启appendonly.aof，同时可以选择在访问较少的时间每天对appendonly.aof进行重写一次。   

●appendfsync   
设置对appendonly.aof文件进行同步的频率。always表示每次有写操作都进行同步，everysec表示对写操作进行累积，每秒同步一次。这个需要根据实际业务场景进行配置。   

●vm-enabled   
是否开启虚拟内存支持。因为redis是一个内存数据库，而且当内存满的时候，无法接收新的写请求，所以在redis 2.0中，提供了虚拟内存的支持。但是需要注意的是，redis中，所有的key都会放在内存中，在内存不够时，只会把value值放入交换区。这样保证了虽然使用虚拟内存，但性能基本不受影响，同时，你需要注意的是你要把vm-max-memory设置到足够来放下你的所有的key。   

●vm-swap-file   
设置虚拟内存的交换文件路径。   

●vm-max-memory   
这里设置开启虚拟内存之后，redis将使用的最大物理内存的大小。默认为0，redis将把他所有的能放到交换文件的都放到交换文件中，以尽量少的使用物理内存。在生产环境下，需要根据实际情况设置该值，最好不要使用默认的0。   

●vm-page-size   
设置虚拟内存的页大小，如果你的value值比较大，比如说你要在value中放置博客、新闻之类的所有文章内容，就设大一点，如果要放置的都是很小的内容，那就设小一点。   

●vm-pages   
设置交换文件的总的page数量，需要注意的是，page table信息会放在物理内存中，每8个page就会占据RAM中的1个byte。总的虚拟内存大小 = vm-page-size * vm-pages。   

●vm-max-threads   
设置VM IO同时使用的线程数量。因为在进行内存交换时，对数据有编码和解码的过程，所以尽管IO设备在硬件上本上不能支持很多的并发读写，但是还是如果你所保存的vlaue值比较大，将该值设大一些，还是能够提升性能的。   

●glueoutputbuf   
把小的输出缓存放在一起，以便能够在一个TCP packet中为客户端发送多个响应，具体原理和真实效果我不是很清楚。所以根据注释，你不是很确定的时候就设置成yes。   

●hash-max-zipmap-entries   
在redis 2.0中引入了hash数据结构。当hash中包含超过指定元素个数并且最大的元素没有超过临界时，hash将以一种特殊的编码方式(大大减少内存使用)来存储，这里可以设置这两个临界值。   

●activerehashing   
开启之后，redis将在每100毫秒时使用1毫秒的CPU时间来对redis的hash表进行重新hash，可以降低内存的使用。当你的使用场景中，有非常严格的实时性需要，不能够接受Redis时不时的对请求有2毫秒的延迟的话，把这项配置为no。如果没有这么严格的实时性要求，可以设置为yes，以便能够尽可能快的释放内存。   
我们可以通过更改daemonize选项为yes进行实验。

先将之前运行的./src/redis-server停止，然后通过

	./src/redis-server redis.conf
运行redis，我们可以看见这次并没有进入redis。但是通过

	netstate -anlp | grep 6379
来查看端口。

	[root@localhost redis-3.2.8]# netstat -anlp | grep 6379
	tcp        0      0 127.0.0.1:6379              0.0.0.0:*                   LISTEN      6206/./src/redis-se 

此时通过

	./src/redis-cli
就可以进入交互式界面进行操作。

4. redis密码配置
		
    
    vim /etc/redis/6379.conf
        requirepass jspt-redis
    或者
	./src/redis-cli   #进入交互式命令界面
	redis>  config set requirepass 123  #将密码配置为123
	#此时，在这个交互界面的所有命令都会被拒绝，需要退出之后通过密码登录
	src/redis-cli -a 123
	redis>  config get requirepass   #查看密码
	1) "requirepass"
	2) "123"
    #尽量使用第一种方式

5. redis基础命令
#### **strings类型操作**
	
●set #设置key对应的值为string类型的value。

	redis 127.0.0.1:6379> set name HongWan
	OK

●setnx   #设置key对应的值为string类型的value。如果key已经存在，返回0，nx是not exist的意思。

	redis 127.0.0.1:6379> get name   
	"HongWan"
	redis 127.0.0.1:6379> setnx name HongWan_new
	(integer) 0
	redis 127.0.0.1:6379> get name
	"HongWan"
●setex  #设置key对应的值为string类型的value，并指定此键值对应的有效期。例如我们添加一个haircolor= red的键值对，并指定它的有效期是10秒
	
	redis 127.0.0.1:6379> setex haircolor 10 red
	OK
	redis 127.0.0.1:6379> get haircolor
	"red"
	redis 127.0.0.1:6379> get haircolor    （超过10s后）
	(nil)

●setrange  #设置指定key的value值的子字符串。例如我们希望将HongWan的126邮箱替换为gmail邮箱

	redis 127.0.0.1:6379> get name
	"HongWan@126.com"
	redis 127.0.0.1:6379> setrange name 8 gmail.com
	(integer) 17
	redis 127.0.0.1:6379> get name
	"HongWan@gmail.com"      ##其中的8是指从下标为8(包含8)的字符开始替换

●mset   #一次设置多个key的值，成功返回ok表示所有的值都设置了，失败返回0表示没有任何值被设置。

	redis 127.0.0.1:6379> mset key1 HongWan1 key2 HongWan2
	OK
	redis 127.0.0.1:6379> get key1
	"HongWan1"
	redis 127.0.0.1:6379> get key2
	"HongWan2"

●msetnx  #一次设置多个key的值，成功返回ok表示所有的值都设置了，失败返回0表示没有任何值被设置，但是不会覆盖已经存在的key。

	redis 127.0.0.1:6379> get key1
	"HongWan1"
	redis 127.0.0.1:6379> get key2
	"HongWan2"
	redis 127.0.0.1:6379> msetnx key2 HongWan2_new key3 HongWan3
	(integer) 0
	redis 127.0.0.1:6379> get key2
	"HongWan2"
	redis 127.0.0.1:6379> get key3
	(nil)

●get  #获取key对应的string值,如果key不存在返回nil。
　　
	redis 127.0.0.1:6379> get name
	"HongWan"
	redis 127.0.0.1:6379> get name1
	(nil)

●getset  #设置key的值，并返回key的旧值。

	redis 127.0.0.1:6379> get name
	"HongWan"
	redis 127.0.0.1:6379> getset name HongWan_new
	"HongWan"
	redis 127.0.0.1:6379> get name
	"HongWan_new"
	redis 127.0.0.1:6379> getset name1 aaa
	(nil)

●getrange  #获取指定key的value值的子字符串。

	redis 127.0.0.1:6379> get name
	"HongWan@126.com"
	redis 127.0.0.1:6379> getrange name 0 6  #从左第0开始
	"HongWan"
	redis 127.0.0.1:6379> getrange name -7 -1  #从右第一开始
	"126.com"
	redis 127.0.0.1:6379> getrange name 7 100  #超出长度则截止至最大
	"@126.com"

●mget   #一次获取多个key的值，如果对应key不存在，则对应返回nil。

	redis 127.0.0.1:6379> mget key1 key2 key3
	1) "HongWan1"
	2) "HongWan2"
	3) (nil)

●incr #对key的值做加加操作,并返回新的值。注意incr一个不是int的value会返回错误，incr一个不存在的key，则设置key为1

	redis 127.0.0.1:6379> set age 20
	OK
	redis 127.0.0.1:6379> incr age
	(integer) 21
	redis 127.0.0.1:6379> get age
	"21"

●incrby  #同incr类似，加指定值 ，key不存在时候会设置key，并认为原来的value是 0

	redis 127.0.0.1:6379> get age
	"21"
	redis 127.0.0.1:6379> incrby age 5
	(integer) 26
	redis 127.0.0.1:6379> get name
	"HongWan@gmail.com"
	redis 127.0.0.1:6379> get age
	"26"

●decr  #对key的值做的是减减操作，decr一个不存在key，则设置key为-1

	redis 127.0.0.1:6379> get age
	"26"
	redis 127.0.0.1:6379> decr age
	(integer) 25
	redis 127.0.0.1:6379> get age
	"25"

●decrby  #同decr，减指定值。

	redis 127.0.0.1:6379> get age
	"25"
	redis 127.0.0.1:6379> decrby age 5
	(integer) 20
	redis 127.0.0.1:6379> get age
	"20"
	redis 127.0.0.1:6379> get age
	"20"
	redis 127.0.0.1:6379> incrby age -5   #decrby完全是为了可读性，我们完全可以通过incrby一个负值来实现同样效果，反之一样。
	(integer) 15
	redis 127.0.0.1:6379> get age
	"15"

●append  #给指定key的字符串值追加value,返回新字符串值的长度。例如我们向name的值追加一个@126.com字符串，那么可以这样做:

	redis 127.0.0.1:6379> append name @126.com
	(integer) 15
	redis 127.0.0.1:6379> get name
	"HongWan@126.com"

●strlen  #取指定key的value值的长度。

	redis 127.0.0.1:6379> get name
	"HongWan_new"
	redis 127.0.0.1:6379> strlen name
	(integer) 11
	redis 127.0.0.1:6379> get age
	"15"
	redis 127.0.0.1:6379> strlen age
	(integer) 2

#### **hash类型操作**

Redis hash是一个string类型的field和value的映射表.它的添加、删除操作都是O(1)(平均)。hash特别适合用于存储对象。相较于将对象的每个字段存成单个string类型。将一个对象存储在hash类型中会占用更少的内存，并且可以更方便的存取整个对象。省内存的原因是新建一个hash对象时开始是用zipmap(又称为small hash)来存储的。这个zipmap其实并不是hash table，但是zipmap相比正常的hash实现可以节省不少hash本身需要的一些元数据存储开销。尽管zipmap的添加，删除，查找都是O(n)，但是由于一般对象的field数量都不太多。所以使用zipmap也是很快的,也就是说添加删除平均还是O(1)。如果field或者value的大小超出一定限制后，Redis会在内部自动将zipmap替换成正常的hash实现. 这个限制可以在配置文件中指定
　　`hash-max-zipmap-entries 64 #配置字段最多64个。`
　　`hash-max-zipmap-value 512 #配置value最大为512字节。`
  
  
●hset  #设置hash field为指定值，如果key不存在，则先创建。

	redis 127.0.0.1:6379> hset myhash field1 Hello
	(integer) 1

●hsetnx  #设置hash field为指定值，如果key不存在，则先创建。如果field已经存在，返回0，nx是not exist的意思。

	redis 127.0.0.1:6379> hsetnx myhash field "Hello"
	(integer) 1
	redis 127.0.0.1:6379> hsetnx myhash field "Hello"
	(integer) 0

●hmset  #同时设置hash的多个field。

	redis 127.0.0.1:6379> hmset myhash field1 Hello field2 World
	OK

●hget  #获取指定的hash field。

	redis 127.0.0.1:6379> hget myhash field1
	"Hello"
	redis 127.0.0.1:6379> hget myhash field2
	"World"
	redis 127.0.0.1:6379> hget myhash field3
	(nil)

●hmget    #获取全部指定的hash filed。

	redis 127.0.0.1:6379> hmget myhash field1 field2 field3
	1) "Hello"
	 2) "World"
	3) (nil)

●hincrby  #指定的hash filed 加上给定值。

	redis 127.0.0.1:6379> hset myhash field3 20
	(integer) 1
	redis 127.0.0.1:6379> hget myhash field3
	"20"
	redis 127.0.0.1:6379> hincrby myhash field3 -8
	(integer) 12
	redis 127.0.0.1:6379> hget myhash field3
	"12"

●hexists  #测试指定field是否存在。

	redis 127.0.0.1:6379> hexists myhash field1
	(integer) 1
	redis 127.0.0.1:6379> hexists myhash field9
	(integer) 0

●hlen  #返回指定hash的field数量。

	redis 127.0.0.1:6379> hlen myhash
	(integer) 4

●hdel  #返回指定hash的field数量。

	redis 127.0.0.1:6379> hlen myhash
	(integer) 4
	redis 127.0.0.1:6379> hdel myhash field1
	(integer) 1
	redis 127.0.0.1:6379> hlen myhash
	(integer) 3

●hkeys  #返回hash的所有field。

	redis 127.0.0.1:6379> hkeys myhash
	1) "field2"
	2) "field"
	3) "field3"

●hvals   #返回hash的所有value。

	redis 127.0.0.1:6379> hvals myhash
	1) "World"
	2) "Hello"
	3) "12"

●hgetall  #获取某个hash中全部的filed及value。

	redis 127.0.0.1:6379> hgetall myhash
	1) "field2"
	2) "World"
	3) "field"
	4) "Hello"
	5) "field3"
	6) "12"






