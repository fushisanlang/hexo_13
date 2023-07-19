---
title: Centos6.7设置基于GoogleAuthenticator的二次验证ssh登陆
date: 2019-12-9
updated: 2019-12-10
tags:
  - ssh
  - GoogleAuthenticator
categories:
  - note
abbrlink: 6c80da9d
---


* 环境介绍

```
centos6.7  x86_64 
关闭iptables及selinux
```

* 安装

```shell
yum install wget gcc make pam-devel libpng-devel -y
mkdir /soft -p
cd /soft
wget "http://192.168.1.139/soft/libpam-google-authenticator-1.0-source.tar.bz2" "http://192.168.1.139/soft/qrencode-3.4.4.tar.gz" "http://192.168.1.139/soft/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm"
rpm -ivh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
yum install mercurial
tar -jxvf libpam-google-authenticator-1.0-source.tar.bz2
cd libpam-google-authenticator-1.0
make && make install
cd ..
tar -zvxf qrencode-3.4.4.tar.gz
cd qrencode-3.4.4
./configure --prefix=/usr
make && make install

sed -i '2a,auth required pam_google_authenticator.so' /etc/pam.d/sshd

vim /etc/ssh/sshd_config

	ChallengeResponseAuthentication yes          #修改no为yes
	
service sshd restart
```
* 配置

```shell
google-authenticator

Do you want authentication tokens to be time-based (y/n) y
https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/root@BJLX_NET_TEST-01%3Fsecret%3DCGB5NWP6SABN3TM7  #此地址为绑定时所需的二维码，需要翻墙才可以打开
Your new secret key is: CGB5NWP6SABN3TM7 #如果无法翻墙或者不想使用二维码，就输入这个key进行绑定，账号就是主机名
Your verification code is 730249
Your emergency scratch codes are:  ##需要注意的是：这5个验证码用一个就会少一个！请保存好！需要注意的是：这5个验证码用一个就会少一个！请保存好！
66151894                                              
91475582
37383236
70667696
70522112
Do you want me to update your "/root/.google_authenticator" file (y/n) y       #提示是否要更新验证文件，选择y

Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y    #禁止使用相同口令

By default, tokens are good for 30 seconds and in order to compensate for
possible time-skew between the client and the server, we allow an extra
token before and after the current time. If you experience problems with poor
time synchronization, you can increase the window from its default
size of 1:30min to about 4min. Do you want to do so (y/n) n          #默认动态验证码在30秒内有效，由于客户端和服务器可能会存在时间差，可将时间增加到最长4分钟，是否要这么做：这里选择是n，继续默认30秒

If the computer that you are logging into isn't hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.
Do you want to enable rate-limiting (y/n) y        #是否限制尝试次数，每30秒只能尝试最多3次，这里选择y进行限制
```

