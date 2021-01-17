# On-premisesK8S Cluster Setup with HA control plane.

To do this setup I am stopping firewalld and disabling selinux.
For security reson If you want to use iptables you have to add rules for following ports

- TCP	Inbound	6443*	Kubernetes API server	All
- TCP	Inbound	2379-2380	etcd server client API	kube-apiserver, etcd
- TCP	Inbound	10250	kubelet API	Self, Control plane
- TCP	Inbound	10251	kube-scheduler	Self
- TCP	Inbound	10252	kube-controller-manager	Self
- TCP	Inbound	10250	kubelet API	Self, Control plane
- TCP	Inbound	30000-32767	NodePort Services†	All
- TCP	Inbound	8443*	Kubernetes API server	All(if you use haproxy in Control plane nodes)

# Setup Server: 
  - To do this setup I have created 4 centos servers as below.
 
 - brk8scm101 - 192.168.0.221 - 2CPU, 2GB RAM and 40GB HDD
 - brk8scm102 - 192.168.0.222 - 2CPU, 2GB RAM and 40GB HDD
 - brk8scm103 - 192.168.0.223 - 2CPU, 2GB RAM and 40GB HDD
 - brk8scw103 - 192.168.0.224 - 2CPU, 4GB RAM and 40GB HDD
 
 **Step1:** Updated hosts file with following entries. (brk8scvip - this will be our vertual ip for for haproxy)
 
 ```
192.168.0.221 brk8scm101 
192.168.0.222 brk8scm102 
192.168.0.223 brk8scm103 
192.168.0.224 brk8scw101
192.168.0.220 brk8scvip
 ```
**Step2:** Once all the servers are up and running do the HaProxy and Keepalive setup in Control plane nodes.

- [haproxy, keepalive setup document](https://github.com/bishnuroy/Kubernetes/blob/master/k8s_ha_setup/haproxy-keepalive.md).

 
