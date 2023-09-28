---
title: traefik配置demo
tags:
  - cka
  - k8s
  - kubernetes
categories:
  - note
date: 2023-09-19 00:00:00
---

* middleware-ipwhitelist
```shell
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: ipwhitelist
spec:
  ipWhiteList:
    sourceRange:
    - 127.0.0.1/32
```    

* middleware-stripprefix
```shell
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: stripprefix
spec:
  stripPrefix:
    prefixes:
    - /admin
```    

* middleware-hstsheader
```shell
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: hstsheader
spec:
  headers:
    accessControlMaxAge: 100
    addVaryHeader: true
    stsSeconds: 31536000
    stsIncludeSubdomains: true
    stsPreload: true
    forceSTSHeader: true
    accessControlAllowCredentials: true
    accessControlAllowOriginList:
      - "baiud.com"
    accessControlExposeHeaders:
    customRequestHeaders:
      hello: "world"
    accessControlAllowMethods:
      - "GET"
      - "POST"
      - "PUT"
      - "OPTIONS"
      - "DELETE"
    accessControlAllowHeaders:
      - content-type
      - x-requested-with
      - timeoffset
```          

* ingressroute
```shell
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: ingressroute
spec:
  entryPoints:
    - websecure
  routes:
  - kind: Rule
    match: Host(`a.com`) && PathPrefix(`/a`)
    priority: 20
    middlewares:
    - name: stripprefix
    services:
    - kind: Service
      name: api
      port: 9443
      scheme: https     
  tls:
    store:
      name: default
```