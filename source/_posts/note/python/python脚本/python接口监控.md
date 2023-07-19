---
title: 接口响应监控
date: 2016-8-13
updated: 2016-8-14
tags:
  - python
categories:
  - demo
abbrlink: e96dde8d
---

```python
#脚本可以在python2和python3环境运行。
#用于监控接口的响应。如果接口响应正常，不做操作。有响应但是返回异常。通过邮件发送异常json。
#没有响应则发送告警邮件并重启服务。
#使用时，请将所以注释删除。
import requests
import json
from smtplib import SMTP_SSL
from email.header import Header
from email.mime.text import MIMEText
import os
import time

#定义发送函数，调用时传入邮件正文内容，其他预定义好
def sendmail(txt_str):
    #邮件服务器地址，因为是ssl信箱地址，选用ssl方法，默认调用465端口
    smtp = SMTP_SSL("smtp.exmail.qq.com")
    #debug模式
    #smtp.set_debuglevel(1)
    smtp.ehlo("smtp.exmail.qq.com")
    #邮件服务的用户密码,password需要替换
    smtp.login("zhangying@aegis-data.cn", "password")
    #邮件正文，通过txt_str参数传入
    msg = MIMEText(txt_str, "plain", "utf-8")
    #邮件标题
    msg["Subject"] = Header('monitor', "utf-8")
    #定义发件人和收件人
    msg["from"] = "zhangying@aegis-data.cn"
    msg["to"] = "313346216@qq.com"
    #发送操作
    smtp.sendmail("zhangying@aegis-data.cn", "313346216@qq.com", msg.as_string())
    smtp.quit()
    return

#此处while true，是为了防止重启后服务依然有问题。
#通过睡眠（服务启动时间）后重新探测接口。
#如果依旧异常，那么再次重启服务，直至接口可以正常访问。
while True:
    try:
        #接口地址
        url = "http://127.0.0.1/json.html"
        #使用get方法获得json，可以换作post方法并添加认证参数
        result = requests.request("get",url,)
        #模拟结果如下：
        #{ "date": "20190922 10:10:01", "running": "ok", "errorcode": "1" }
        #将json转为字典形式
        result_dict=json.loads(result.text)
        #打印running的值
        #print(result_dict['running'])
    
        #对running的值做判断，如果是ok,跳出循环。不是ok，执行操作后跳出循环
        if result_dict['running'] == 'ok':
            #print('ok')
            break
        else:
            #将字典转为字符串，否则无法传入sendmail函数
            note=json.dumps(result_dict)
            #将异常json全部传入sendmail，发送邮件
            sendmail(note)
            print('sendmail ok.')
            break
    
    #访问异常处理
    except:
        #发送报警邮件，提示将要重启
        sendmail('error,restart app')
        print('sendmail ok.')
        #通过事先编写好的shell脚本，重启服务
        #os.system('sh /dir/shell_file.sh')
        #此处使用nginx起停模拟接口异常，所以操作换为启动nginx
        os.system('systemctl start nginx')
        #睡眠时间应该根据应用启动时间进行调整，此处用1s，方便测试
        time.sleep(1)

```
