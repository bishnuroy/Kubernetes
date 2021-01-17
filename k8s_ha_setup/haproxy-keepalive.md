## Install and Configure Keepalive and HAProxy

**Step1:** Install keepalived and haproxy on all the master nodes.

- yum install haproxy keepalived -y

**Step2:**
- Take the backup of keepalived.conf and haproxy.conf file.
  - cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf-org
  - cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg-org
- Truncate the files.
  - sh -c '> /etc/keepalived/keepalived.conf'
  - sh -c '> /etc/haproxy/haproxy.cfg'
- Now repalce the files with following content, change ip or host name as per your envirinment

**Step3:**
**keepalived.conf**

```
! /etc/keepalived/keepalived.conf
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
}
vrrp_script check_apiserver {
  script "/etc/keepalived/apiserver_check.sh"
  interval 3
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface ens33
    virtual_router_id 151
    priority 255
    authentication {
        auth_type PASS
        auth_pass Pass@123D!
    }
    virtual_ipaddress {
        192.168.0.220/24
    }
    track_script {
        check_apiserver
    }
}

```

 - Note: 
    - state will be "SLAVE" in other 2 nodes.
    - And priority will be less then master, here 255 for the master then other 2 nodes it will be 254 and 253.
 
 - Create "/etc/keepalived/apiserver_check.sh" script for keepalive check
 ```
 #!/bin/sh
APISERVER_VIP=192.168.0.220
APISERVER_DEST_PORT=6443

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

curl --silent --max-time 2 --insecure https://localhost:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://localhost:${APISERVER_DEST_PORT}/"
if ip addr | grep -q ${APISERVER_VIP}; then
    curl --silent --max-time 2 --insecure https://${APISERVER_VIP}:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://${APISERVER_VIP}:${APISERVER_DEST_PORT}/"
fi
 ```
    - Set execute permission "chmod +x /etc/keepalived/apiserver_check.sh"
 
 **Step4:**
 
**haproxy.cfg** add this file in all the haproxy cluster nodes.

```
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
    #errorfile 400 /var/log/haproxy/error.log
    #errorfile 403 /var/log/haproxy/error.log
    #errorfile 408 /var/log/haproxy/error.log
    #errorfile 500 /var/log/haproxy/error.log
    #errorfile 502 /var/log/haproxy/error.log
    #errorfile 503 /var/log/haproxy/error.log
    #errorfile 504 /var/log/haproxy/error.log

listen stats
    bind :32700
    stats enable
    stats uri /status
    stats hide-version
    stats auth broy:redhat

#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
# apiserver frontend which proxys to the masters
#---------------------------------------------------------------------

########################################

# apiserver frontend which proxys to the masters
#---------------------------------------------------------------------
frontend apiserver
    bind *:8443
    mode tcp
    option tcplog
    reqadd X-Forwarded-Proto:\ http
    default_backend apiserver
#---------------------------------------------------------------------
# round robin balancing for apiserver
#---------------------------------------------------------------------
backend apiserver
    #option httpchk GET /healthz
    #http-check expect status 200
    mode tcp
    #option ssl-hello-chk
    option forwardfor
    balance     roundrobin
    http-request set-header X-Forwarded-Port %[dst_port]
    #http-request add-header X-Forwarded-Proto https if { ssl_fc }
    server brk8scm101 192.168.0.221:6443 check
    server brk8scm102 192.168.0.222:6443 check
    server brk8scm103 192.168.0.223:6443 check

```
- I have added below parameter to gate the haproxy status, this is optional.

```
listen stats
    bind :32700
    stats enable
    stats uri /status
    stats hide-version
    stats auth broy:redhat
```
**Step5**

- Resttart the services.
  - systemctl strat keepalived.service
  - systemctl enable keepalived --now
  - systemctl strat  haproxy
  - systemctl enable haproxy --now

Demo Deshboard of the haproxy status.

![HAPROXY-Status-Dashboard](https://github.com/bishnuroy/Kubernetes/blob/master/k8s_ha_setup/haproxy_status.png)




REF: https://github.com/kubernetes/kubeadm/blob/master/docs/ha-considerations.md#options-for-software-load-balancing
