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
 
 To do this setup I have created 4 centos servers as below.
 
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

**Step3**

- Disable Swap Space on all the nodes including worker nodes.
  - swapoff -a
  - sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
- Install Docker (Container Run Time) on all the nodes
  - yum install -y yum-utils
  - yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  - yum install docker-ce -y
  - systemctl enable docker --now
  - systemctl start docker
  
**Step4**
- Set repo for kuberneties packages.
```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
```
- Install kubeadm, kubelet and kubectl on all master nodes and worker nodes.
  - yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
  - systemctl enable kubelet --now
  - sh -c "echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"
  - sh -c "echo '1' > /proc/sys/net/ipv4/ip_forward"

**Step5:**
- Now initialize the Kubernetes Cluster from 1st master node.
  - kubeadm init --control-plane-endpoint "192.168.0.220:8443" --upload-certs  (Here 192.168.0.220 virtual ip, you can use hostname also"
```
root@brk8scm101 ~]# kubeadm init --control-plane-endpoint "192.168.0.220:8443" --upload-certs
[init] Using Kubernetes version: v1.20.2
[preflight] Running pre-flight checks
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
	[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 20.10.2. Latest validated version: 19.03
	[WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [brk8scm101 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.0.221 192.168.0.220]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [brk8scm101 localhost] and IPs [192.168.0.221 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [brk8scm101 localhost] and IPs [192.168.0.221 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "admin.conf" kubeconfig file
[endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 19.047909 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.20" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
7fcb8b8d2066b8e2a48823017bd8f3bc3d4e8e2efb1c2861a1e96c145e61cb0c
[mark-control-plane] Marking the node brk8scm101 as control-plane by adding the labels "node-role.kubernetes.io/master=''" and "node-role.kubernetes.io/control-plane='' (deprecated)"
[mark-control-plane] Marking the node brk8scm101 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: q9jcsy.nm9fce4x4pmd15tv
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 192.168.0.220:8443 --token q9jcsy.nm9fce4x4pmd15tv \
    --discovery-token-ca-cert-hash sha256:ef0e9b1d54ec9ad8df0131d3f88fed163dea12fd7c1d0a9a80ee1de2586cc055 \
    --control-plane --certificate-key 7fcb8b8d2066b8e2a48823017bd8f3bc3d4e8e2efb1c2861a1e96c145e61cb0c

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.0.220:8443 --token q9jcsy.nm9fce4x4pmd15tv \
    --discovery-token-ca-cert-hash sha256:ef0e9b1d54ec9ad8df0131d3f88fed163dea12fd7c1d0a9a80ee1de2586cc055
[root@brk8scm101 ~]#
```

- Run followig commands to allow local user to access the cluster.
  - mkdir -p $HOME/.kube
  - cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  - chown $(id -u):$(id -g) $HOME/.kube/config
  
**Step6:** Install pod network - I am using Calico
- Link: https://docs.projectcalico.org/manifests/calico.yaml (this will point you updated version)
- Or You can check https://github.com/projectcalico/calico this repo to get more info about calico
  - Command:  kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

**Step7:**
- As per instraction of Step5 output execute below command(On other Master Nodes) to Join rest of the master node to the cluster.
```
kubeadm join 192.168.0.220:8443 --token q9jcsy.nm9fce4x4pmd15tv \
    --discovery-token-ca-cert-hash sha256:ef0e9b1d54ec9ad8df0131d3f88fed163dea12fd7c1d0a9a80ee1de2586cc055 \
    --control-plane --certificate-key 7fcb8b8d2066b8e2a48823017bd8f3bc3d4e8e2efb1c2861a1e96c145e61cb0c
```
- As per instraction of Step5 output execute below command(On other Orker Nodes) to Join worker node in the cluster.
```
kubeadm join 192.168.0.220:8443 --token q9jcsy.nm9fce4x4pmd15tv \
    --discovery-token-ca-cert-hash sha256:ef0e9b1d54ec9ad8df0131d3f88fed163dea12fd7c1d0a9a80ee1de2586cc055
```

**Output of the cluster status**
```
[root@brk8scm101 ~]# kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes -o wide
NAME         STATUS   ROLES                  AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION                CONTAINER-RUNTIME
brk8scm101   Ready    control-plane,master   21h   v1.20.2   192.168.0.221   <none>        CentOS Linux 7 (Core)   3.10.0-1160.11.1.el7.x86_64   docker://20.10.2
brk8scm102   Ready    control-plane,master   21h   v1.20.2   192.168.0.222   <none>        CentOS Linux 7 (Core)   3.10.0-1160.11.1.el7.x86_64   docker://20.10.2
brk8scm103   Ready    control-plane,master   16h   v1.20.2   192.168.0.223   <none>        CentOS Linux 7 (Core)   3.10.0-1160.11.1.el7.x86_64   docker://20.10.2
brk8scw101   Ready    <none>                 15h   v1.20.2   192.168.0.224   <none>        CentOS Linux 7 (Core)   3.10.0-1160.11.1.el7.x86_64   docker://20.10.2
[root@brk8scm101 ~]#
```



