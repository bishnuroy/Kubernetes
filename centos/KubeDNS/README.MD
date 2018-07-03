Once Cluster Ready deploy [kubedns.yaml](https://github.com/bishnuroy/Kubernetes/blob/master/centos/KubeDNS/kubedns.yaml) in cluster.

Login every worker node and execute below nolookup command. 
Your kubeDns is working properly If you get below outputs.

```console
# nslookup kubernetes.default.svc.cluster.local 10.100.0.2
Server:		10.100.0.2
Address:	10.100.0.2#53

Non-authoritative answer:
Name:	kubernetes.default.svc.cluster.local
Address: 10.100.0.1
```
