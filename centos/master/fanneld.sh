#!/usr/bin/env bash

#ETCD_SERVERS=${1:-"http://8.8.8.18:4001"}
ETCD_SERVERS=${1:-"http://etcd-node1-ip:2379,http://etcd-node2-ip:2379,http://etcd-node3-ip:2379"}
FLANNEL_NET=${2:-"172.16.0.0/16"}

#CA_FILE="/opt/kubernetes/etcd/ca.pem"
#CERT_FILE="/opt/kubernetes/etcd/client.pem"
#KEY_FILE="/opt/kubernetes/etcd/client-key.pem"

cat <<EOF >/opt/kubernetes/cfg/flannel
FLANNEL_ETCD="-etcd-endpoints=${ETCD_SERVERS}"
FLANNEL_ETCD_KEY="-etcd-prefix=/coreos.com/network"
#FLANNEL_ETCD_CAFILE="--etcd-cafile=${CA_FILE}"
#FLANNEL_ETCD_CERTFILE="--etcd-certfile=${CERT_FILE}"
#FLANNEL_ETCD_KEYFILE="--etcd-keyfile=${KEY_FILE}"
EOF

cat <<EOF >/usr/lib/systemd/system/flannel.service
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
[Service]
EnvironmentFile=-/opt/kubernetes/cfg/flannel
ExecStart=/opt/kubernetes/bin/flanneld --ip-masq \${FLANNEL_ETCD} \${FLANNEL_ETCD_KEY}
Type=notify
[Install]
WantedBy=multi-user.target
EOF

# Store FLANNEL_NET to etcd.
attempt=0
while true; do
  /bin/etcdctl --no-sync -C ${ETCD_SERVERS} \
    get /coreos.com/network/config >/dev/null 2>&1
  if [[ "$?" == 0 ]]; then
    break
  else
    if (( attempt > 600 )); then
      echo "timeout for waiting network config" > ~/kube/err.log
      exit 2
    fi

    /bin/etcdctl --no-sync -C ${ETCD_SERVERS} \
      mk /coreos.com/network/config "{\"Network\":\"${FLANNEL_NET}\"}" >/dev/null 2>&1
    attempt=$((attempt+1))
    sleep 3
  fi
done
wait

systemctl enable flannel
systemctl daemon-reload
systemctl restart flannel
