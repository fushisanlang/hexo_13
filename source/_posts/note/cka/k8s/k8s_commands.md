---
title: kubernetes学习笔记0-命令
tags:
  - cka
  - k8s
  - kubernetes
categories:
  - note
date: 2023-09-19 00:00:00
---

```shell

kubectl scale deploy --replicas=0 <Deployment名称> -n <Namespace名称>
docker run --rm -v //var/run/docker.sock:/var/run/docker.sock -v ~/Desktop:/root/trivy trivy:latest -trivy_args "--skip-update --ignore-unfixed ${1}" -report_name report${date} -local_report_path /root/trivy
kubectl rollout restart deploy
```