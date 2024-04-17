---
title: aks添加nodepool
date: 2024-3-20
tags:
  - azure
  - Azure Cli
  - aks
categories:
  - note
abbrlink: d67b3a47
---
```shell
az aks nodepool add \
    --resource-group xxx \
    --cluster-name xxx \
    --name xxx \
    --node-count 1 \
    --min-count 1 \
    --max-count 25 \
    --node-vm-size standard_e20as_v4 \
    --vnet-subnet-id "/subscriptions/xxxx/resourceGroups/DEV_AKS/providers/Microsoft.Network/virtualNetworks/vnet-aks-applications/subnets/xxxx" \
    --node-taints usedto=nnx:NoSchedule \
    --enable-cluster-autoscaler
```