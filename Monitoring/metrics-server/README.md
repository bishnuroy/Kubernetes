# Kubernetes Monitoring

## We have various component avalable by those we can do monitor our K8S clustes resourcers.

- Matrics Server
- Heapster (Deprecated)
- Promethous
- Elastic Stack
- DATADOG
- dynatrace


**Deploy "Matrics Server"**

 - wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml .
 - In components.yaml file there will be "- args:" section on deployment, add "- --kubelet-insecure-tls" this parameter if you see any ssl error after deploy      default file. It will solv the certificate error.
 - kubectl --kubeconfig=brk8s01-admin.conf apply -f components.yaml
 ```
 Bishnus-MacBook-Pro-2:~ bishnuroy$ kubectl --kubeconfig=brk8s01-admin.conf top node
NAME                        CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
brk8sm01.br.example.com   305m         15%    2247Mi          60%       
brk8sm02.br.example.com   215m         10%    1937Mi          52%       
brk8sm03.br.example.com   253m         12%    2027Mi          54%       
brk8sw01.br.example.com   166m         4%     1508Mi          9%        
brk8sw02.br.example.com   162m         4%     1468Mi          9%        
brk8sw03.br.example.com   168m         4%     1454Mi          9%        
Bishnus-MacBook-Pro-2:~ bishnuroy$
 ```
 ```
 Bishnus-MacBook-Pro-2:~ bishnuroy$ kubectl --kubeconfig=brk8s01-admin.conf top pod -n kube-system
NAME                                                CPU(cores)   MEMORY(bytes)   
calico-kube-controllers-744cfdf676-l4tzw            2m           35Mi            
calico-node-8cq7t                                   43m          178Mi           
calico-node-c56p4                                   32m          173Mi           
calico-node-d4lkf                                   32m          146Mi           
calico-node-g7gff                                   34m          138Mi           
calico-node-q8bp5                                   34m          173Mi           
calico-node-tmz5g                                   38m          114Mi           
coredns-f9fd979d6-9zth2                             4m           20Mi            
coredns-f9fd979d6-lc9b5                             4m           28Mi            
etcd-brk8sm01.br.example.com                        61m          350Mi           
etcd-brk8sm02.br.example.com                        45m          341Mi           
etcd-brk8sm03.br.example.com                        45m          348Mi           
kube-apiserver-brk8sm01.br.example.com              66m          540Mi           
kube-apiserver-brk8sm02.br.example.com              48m          447Mi           
kube-apiserver-brk8sm03.br.example.com              58m          507Mi           
kube-controller-manager-brk8sm01.br.example.com     19m          76Mi            
kube-controller-manager-brk8sm02.br.example.com     2m           30Mi            
kube-controller-manager-brk8sm03.br.example.com     3m           28Mi            
kube-proxy-2kzsb                                    1m           20Mi            
kube-proxy-7j9mz                                    1m           22Mi            
kube-proxy-jp9w6                                    1m           21Mi            
kube-proxy-k7phl                                    1m           22Mi            
kube-proxy-lvf96                                    1m           23Mi            
kube-proxy-zkg6b                                    1m           22Mi            
kube-scheduler-brk8sm01.br.example.com              5m           34Mi            
kube-scheduler-brk8sm02.br.example.com              3m           25Mi            
kube-scheduler-brk8sm03.br.example.com              3m           27Mi            
kube-vip-brk8sm01.br.example.com                    1m           25Mi            
kube-vip-brk8sm02.br.example.com                    1m           21Mi            
kube-vip-brk8sm03.br.example.com                    3m           24Mi            
metrics-server-5b78d5f9c6-swgx6                     5m           18Mi            
Bishnus-MacBook-Pro-2:~ bishnuroy$
 ```
