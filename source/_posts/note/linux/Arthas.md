---
title: Arthas
date: 2021-2-5
tags:
  - Arthas
categories:
  - note
abbrlink: e1a71cf6
---

## 简介
Arthas 是阿里开源的 Java 诊断工具，深受开发者喜爱。在线排查问题，无需重启；动态跟踪 Java 代码；实时监控 JVM 状态。Arthas 支持 JDK 6+，支持 Linux/Mac/Windows，采用命令行交互模式，同时提供丰富的 Tab 自动补全功能，进一步方便进行问题的定位和诊断

## Arthas可以解决什么问题？
Arthas 是Alibaba开源的Java诊断工具，深受开发者喜爱。当你遇到以下类似问题而束手无策时，Arthas可以帮助你解决：
* 这个类从哪个 jar 包加载的？为什么会报各种类相关的 Exception？
* 我改的代码为什么没有执行到？难道是我没 commit？分支搞错了？
* 遇到问题无法在线上 debug，难道只能通过加日志再重新发布吗？
* 线上遇到某个用户的数据处理有问题，但线上同样无法 debug，线下无法重现！
* 是否有一个全局视角来查看系统的运行状况？
* 有什么办法可以监控到JVM的实时运行状态？
* 怎么快速定位应用的热点，生成火焰图？
* 怎样直接从JVM内查找某个类的实例？

### 下载与安装Arthas
考虑后续生产是非互联网环境，所以采用全量包安装方法。本次使用arthas-bin.zip（3.5.1）版本进行部署实验，可前往Maven仓库或Github Releases下载，下载地址：https://github.com/alibaba/arthas/releases

#### 上传Arthas全量安装包至服务器
```shell
#安装JDK1.8，添加当前用户的java环境变量
[ccb-yth@APPSRV01 tools]$ cat ~/.bash_profile 
PATH=$PATH:$HOME/.local/bin:$HOME/bin
JAVA_HOME=/home/ap/ccb-yth/java/jdk1.8.0_291
export JAVA_HOME
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export CLASSPATH
PATH=$JAVA_HOME/bin:$PATH:$HOME/bin:$JAVA_HOME/bin
export PATH

#验证JDK环境是否正常
[ccb-yth@APPSRV01 tools]$ java -version
java version "1.8.0_291"
Java(TM) SE Runtime Environment (build 1.8.0_291-b10)
Java HotSpot(TM) 64-Bit Server VM (build 25.291-b10, mixed mode)

#将arthas-bin.zip（3.5.1）解压到此目录
[ccb-yth@APPSRV01 tools]$ pwd
/home/ap/ccb-yth/tools

#arthas-boot.jar为启动的监听jar包
[ccb-yth@APPSRV01 tools]$ ll
total 13492
-rw-rw-r-- 1 ccb-yth ccb-yth     8470 Sep 27  2020 arthas-agent.jar
-rw-rw-r-- 1 ccb-yth ccb-yth   141721 Sep 27  2020 arthas-boot.jar
-rw-rw-r-- 1 ccb-yth ccb-yth   431033 Sep 27  2020 arthas-client.jar
-rw-rw-r-- 1 ccb-yth ccb-yth 13143726 Sep 27  2020 arthas-core.jar
drwxrwxr-x 2 ccb-yth ccb-yth        6 Jun 16 18:40 arthas-output
-rw-rw-r-- 1 ccb-yth ccb-yth      403 Sep 27  2020 arthas.properties
-rw-rw-r-- 1 ccb-yth ccb-yth     8988 Sep 27  2020 arthas-spy.jar
-rwxrwxr-x 1 ccb-yth ccb-yth     3113 Sep 27  2020 as.bat
-rwxrwxr-x 1 ccb-yth ccb-yth     7744 Sep 27  2020 as-service.bat
-rwxr-xr-x 1 ccb-yth ccb-yth    32781 Sep 27  2020 as.sh
drwxr-xr-x 2 ccb-yth ccb-yth      156 Sep 27  2020 async-profiler
-rwxr-xr-x 1 ccb-yth ccb-yth      635 Sep 27  2020 install-local.sh
drwxr-xr-x 2 ccb-yth ccb-yth      112 Sep 27  2020 lib
-rw-rw-r-- 1 ccb-yth ccb-yth     2020 Sep 27  2020 logback.xml
-rw-rw-r-- 1 ccb-yth ccb-yth     4506 Sep 27  2020 math-game.jar
```

#### 启动Arthas
* 使用java -jar的方式启动
```shell
java -jar arthas-boot.jar
```
* 打印帮助信息：
```shell
java -jar arthas-boot.jar -h
```

### Arthas的基本使用方法
#### 启动测试程序math-game
math-game是一个简单的程序，每隔一秒生成一个随机数，再执行质因数分解，并打印出分解结果
```shell
[ccb-yth@APPSRV01 tools]$ java -jar math-game.jar
204915=3*5*19*719
illegalArgumentCount:  1, number is: -121796, need >= 2
illegalArgumentCount:  2, number is: -166805, need >= 2
18271=11*11*151
illegalArgumentCount:  3, number is: -126135, need >= 2
illegalArgumentCount:  4, number is: -85911, need >= 2
```

#### 启动arthas，attach到java进程
在命令行下面执行 `java -jar arthas-boot.jar` （使用和目标进程一致的用户启动，否则可能attach失败）
如果attach不上目标进程，可以查看~/logs/arthas/ 目录下的日志。
`java -jar arthas-boot.jar -h `打印更多参数信息。

```shell
[ccb-yth@APPSRV01 tools]$ java -jar arthas-boot.jar
[INFO] arthas-boot version: 3.5.1
```
* 选择监听的java进程
```shell
[INFO] Found existing java process, please choose one and input the serial number of the process, eg : 1. Then hit ENTER.
* [1]: 9462 math-game.jar
  [2]: 10344 /home/ap/ccb-yth/apps/data-collector/data-collector.jar
```
* math-game进程是第1个，则输入1，再敲回车。Arthas会attach到目标进程上，并输出日志

```shell
[INFO] arthas home: /home/ap/ccb-yth/tools
[INFO] Try to attach process 9462
[INFO] Attach process 9462 success.
[INFO] arthas-client connect 127.0.0.1 3658
  ,---.  ,------. ,--------.,--.  ,--.  ,---.   ,---.                           
 /  O  \ |  .--. ''--.  .--'|  '--'  | /  O  \ '   .-'                          
|  .-.  ||  '--'.'   |  |   |  .--.  ||  .-.  |`.  `-.                          
|  | |  ||  |\  \    |  |   |  |  |  ||  | |  |.-'    |                         
`--' `--'`--' '--'   `--'   `--'  `--'`--' `--'`-----'                          
                                                                                

wiki       https://arthas.aliyun.com/doc                                        
tutorials  https://arthas.aliyun.com/doc/arthas-tutorials.html                  
version    3.5.1                                                                
main_class                                                                      
pid        9462                                                                 
time       2021-06-17 10:22:09  
[arthas@9462]$
```

#### 查看dashboard
命令行输入dashboard，按回车，会展示当前进程的信息，按ctrl+c可以中断执行
当arthas附加到进程后，命令行提示符会变为[arthas@xxx]$，表明附加成功
```
[arthas@9462]$ dashboard
```

#### 通过thread命令来获取到math-game进程的Main Class
thread 1会打印线程ID 1的栈，通常是main函数的线程。一目了然的了解系统的状态，哪些线程比较占cpu？他们到底在做什么？
```
[arthas@9462]$ thread 1 | grep 'main('
    at demo.MathGame.main(MathGame.java:17)
```

#### 通过jad来反编译Main Class
``` 
[arthas@9462]$ jad demo.MathGame

ClassLoader:                                                                                                                                                      
+-sun.misc.Launcher$AppClassLoader@70dea4e                                                                                                                        
  +-sun.misc.Launcher$ExtClassLoader@68833bb2                                                                                                                     

Location:                                                                                                                                                         
/home/ap/ccb-yth/tools/math-game.jar                                                                                                                              

       /*
        * Decompiled with CFR.
        */
       package demo;
       
       import java.util.ArrayList;
       import java.util.List;
       import java.util.Random;
       import java.util.concurrent.TimeUnit;
       
       public class MathGame {
           private static Random random = new Random();
           private int illegalArgumentCount = 0;
       
           public List<Integer> primeFactors(int number) {
/*44*/         if (number < 2) {
/*45*/             ++this.illegalArgumentCount;
                   throw new IllegalArgumentException("number is: " + number + ", need >= 2");
               }
               ArrayList<Integer> result = new ArrayList<Integer>();
/*50*/         int i = 2;
/*51*/         while (i <= number) {
/*52*/             if (number % i == 0) {
/*53*/                 result.add(i);
/*54*/                 number /= i;
/*55*/                 i = 2;
                       continue;
                   }
/*57*/             ++i;
               }
/*61*/         return result;
           }
       
           public static void main(String[] args) throws InterruptedException {
               MathGame game = new MathGame();
               while (true) {
/*16*/             game.run();
/*17*/             TimeUnit.SECONDS.sleep(1L);
               }
           }
       
           public void run() throws InterruptedException {
               try {
/*23*/             int number = random.nextInt() / 10000;
/*24*/             List<Integer> primeFactors = this.primeFactors(number);
/*25*/             MathGame.print(number, primeFactors);
               }
               catch (Exception e) {
/*28*/             System.out.println(String.format("illegalArgumentCount:%3d, ", this.illegalArgumentCount) + e.getMessage());
               }
           }
       
           public static void print(int number, List<Integer> primeFactors) {
               StringBuffer sb = new StringBuffer(number + "=");
/*34*/         for (int factor : primeFactors) {
/*35*/             sb.append(factor).append('*');
               }
/*37*/         if (sb.charAt(sb.length() - 1) == '*') {
/*38*/             sb.deleteCharAt(sb.length() - 1);
               }
/*40*/         System.out.println(sb);
           }
       }

Affect(row-cnt:1) cost in 745 ms.
```

#### watch指令
通过watch命令来查看demo.MathGame#primeFactors函数的返回值
```
[arthas@9462]$ watch demo.MathGame primeFactors returnObj
Press Q or Ctrl+C to abort.
Affect(class count: 1 , method count: 1) cost in 111 ms, listenerId: 1
method=demo.MathGame.primeFactors location=AtExit
ts=2021-06-17 10:29:00; [cost=2.068011ms] result=@ArrayList[
    @Integer[2],
    @Integer[2],
    @Integer[3],
    @Integer[37],
    @Integer[101],
]
......
```

#### 生成进程火焰图
profiler 命令支持生成应用热点的火焰图。本质上是通过不断的采样，然后把收集到的采样结果生成火焰图。
```
[arthas@10344]$ profiler start
Started [cpu] profiling

[arthas@10344]$ profiler stop
OK
profiler output file: /home/ap/ccb-yth/apps/data-collector/arthas-output/20210617-103942.svg
[arthas@10344]$ exit
[ccb-yth@APPSRV01 tools]$ sz /home/ap/ccb-yth/apps/data-collector/arthas-output/20210617-103942.svg

```

#### 退出arthas
* 如果只是退出当前的连接，可以用quit或者exit命令。Attach到目标进程上的arthas还会继续运行，端口会保持开放，下次连接时可以直接连接上。

* 如果想完全退出arthas，可以执行stop命令
* 