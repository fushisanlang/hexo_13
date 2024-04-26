---
title: azure postgre 关闭进程
date: 2024-4-26
tags:
  - azure
  - postgre sql
categories:
  - note
abbrlink: 404a4725
---
```sql
-- 查找要终止的进程的PID
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE pid <> pg_backend_pid() 
  AND state = 'active';

--这将终止进程ID为 27545 的后台进程
SELECT pg_terminate_backend(27545);
```