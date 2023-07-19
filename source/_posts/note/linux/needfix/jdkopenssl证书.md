---
title: jdk openssl证书
date: 2016-12-14
updated: 2016-12-15
categories:
  - note
abbrlink: 89a7c75d
---
```
cd /usr/java/jdk1.6.0_45/jre/lib/security
keytool -list -keystore cacerts -storepass changeit | grep digicertglobalrootca
keytool -list -keystore cacerts -storepass changeit | grep baltimorecybertrustca
```