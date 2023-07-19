---
title: haproxy启动脚本.sh
date: 2020-9-8
updated: 2020-9-9
tags:
  - haproxy
  - shell
categories:
  - file
abbrlink: 5748ecd5
---
```bash
#!/bin/bash
#
# haproxy
#
# chkconfig: 35 85 15
# description: HAProxy is a free, very fast and reliable solution \
# offering high availability, load balancing, and \
# proxying for TCP and HTTP-based applications
# processname: haproxy
# config: /etc/haproxy.cfg
# pidfile: /var/run/haproxy.pid
# Source function library.
. /etc/rc.d/init.d/functions
# Source networking configuration.
. /etc/sysconfig/network
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
config="/usr/local/haproxy/etc/haproxy.cfg"
exec="/usr/local/haproxy/sbin/haproxy"
prog=$(basename $exec)
[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog
lockfile=/var/lock/subsys/haproxy
check() {
    $exec -c -V -f $config
}
start() {
    $exec -c -q -f $config
    if [ $? -ne 0 ]; then
        echo "Errors in configuration file, check with $prog check."
        return 1
    fi
 
    echo -n $"Starting $prog: "
    # start it up here, usually something like "daemon $exec"
    daemon $exec -D -f $config -p /var/run/$prog.pid
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}
stop() {
    echo -n $"Stopping $prog: "
    # stop it here, often "killproc $prog"
    killproc $prog 
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}
restart() {
    $exec -c -q -f $config
    if [ $? -ne 0 ]; then
        echo "Errors in configuration file, check with $prog check."
        return 1
    fi
    stop
    start
}
reload() {
    $exec -c -q -f $config
    if [ $? -ne 0 ]; then
        echo "Errors in configuration file, check with $prog check."
        return 1
    fi
    echo -n $"Reloading $prog: "
    $exec -D -f $config -p /var/run/$prog.pid -sf $(cat /var/run/$prog.pid)
    retval=$?
    echo
    return $retval
}
force_reload() {
    restart
}
fdr_status() {
    status $prog
}
case "$1" in
    start|stop|restart|reload)
        $1
        ;;
    force-reload)
        force_reload
        ;;
    checkconfig)
        check
        ;;
    status)
        fdr_status
        ;;
    condrestart|try-restart)
      [ ! -f $lockfile ] || restart
    ;;
    *)
        echo $"Usage: $0 {start|stop|status|checkconfig|restart|try
restart|reload|force-reload}"
        exit 2
esac
```
