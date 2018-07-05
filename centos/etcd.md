# Install 3 node etcd cluster.

```
   Yum install etcd -y
```
Edit file "/etc/etcd/etcd.conf" with below details.


### Node1

```
# [member]
 ETCD_NAME=node1
 ETCD_DATA_DIR="/var/lib/etcd/node1.etcd"
 ETCD_LISTEN_PEER_URLS="http://ip-of-the-node1:2380"
 ETCD_LISTEN_CLIENT_URLS="http://ip-of-the-node1:2379,http://127.0.0.1:2379"
 #[cluster]
 ETCD_INITIAL_ADVERTISE_PEER_URLS="http://ip-of-the-node1:2380"
 ETCD_INITIAL_CLUSTER="node1=http://ip-of-the-node1:2380,node2=http://ip-of-the-node2:2380,node3=http://ip-of-the-node3:2380"
 ETCD_INITIAL_CLUSTER_STATE="new"
 ETCD_INITIAL_CLUSTER_TOKEN="etcd-key"
 ETCD_ADVERTISE_CLIENT_URLS="http://ip-of-the-node1:2379"
```

### Node2

```
# [member]
 ETCD_NAME=node2
 ETCD_DATA_DIR="/var/lib/etcd/node2.etcd"
 ETCD_LISTEN_PEER_URLS="http://ip-of-the-node2:2380"
 ETCD_LISTEN_CLIENT_URLS="http://ip-of-the-node2:2379,http://127.0.0.1:2379"
 #[cluster]
 ETCD_INITIAL_ADVERTISE_PEER_URLS="http://ip-of-the-node2:2380"
 ETCD_INITIAL_CLUSTER="node1=http://ip-of-the-node1:2380,node2=http://ip-of-the-node2:2380,node3=http://ip-of-the-node3:2380"
 ETCD_INITIAL_CLUSTER_STATE="new"
 ETCD_INITIAL_CLUSTER_TOKEN="etcd-key"
 ETCD_ADVERTISE_CLIENT_URLS="http://ip-of-the-node2:2379"
```
### Node3

```
# [member]
 ETCD_NAME=node3
 ETCD_DATA_DIR="/var/lib/etcd/node3.etcd"
 ETCD_LISTEN_PEER_URLS="http://ip-of-the-node3:2380"
 ETCD_LISTEN_CLIENT_URLS="http://ip-of-the-node3:2379,http://127.0.0.1:2379"
 #[cluster]
 ETCD_INITIAL_ADVERTISE_PEER_URLS="http://ip-of-the-node3:2380"
 ETCD_INITIAL_CLUSTER="node1=http://ip-of-the-node1:2380,node2=http://ip-of-the-node2:2380,node3=http://ip-of-the-node3:2380"
 ETCD_INITIAL_CLUSTER_STATE="new"
 ETCD_INITIAL_CLUSTER_TOKEN="etcd-key"
 ETCD_ADVERTISE_CLIENT_URLS="http://ip-of-the-node3:2379"
```

Start the service in all the 3 node
```
systemctl enable etcd
systemctl start etcd
```

Once Cluster start execute below command and restart the service.

```
sed -i s'/ETCD_INITIAL_CLUSTER_STATE="new"/ETCD_INITIAL_CLUSTER_STATE="existing"/'g /etc/etcd/etcd.conf

```

```
systemctl restart etcd

```
