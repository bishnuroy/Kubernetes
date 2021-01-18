
**Ref:**
- https://metallb.universe.tf/installation/
- https://github.com/metallb/metallb/tree/main/manifests

**Execute Following Command:**
- kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
- kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
- kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" (Only One Time)

**create ConfigMap** 
- create metallb-cm.yaml file with below contents
```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: my-ip-space
      protocol: layer2
      addresses:
      - 192.168.0.195-192.168.0.199
```
- Execute below command
  - kubectl apply -f metallb-cm.yaml

```
root@brk8sm101:~# kubectl -n metallb-system get all
NAME                              READY   STATUS    RESTARTS   AGE
pod/controller-65db86ddc6-rlwlx   1/1     Running   0          19m
pod/speaker-5b4r5                 1/1     Running   0          11m
pod/speaker-ht9tc                 1/1     Running   0          10m

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/speaker   2         2         2       2            2           kubernetes.io/os=linux   19m

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/controller   1/1     1            1           19m

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/controller-65db86ddc6   1         1         1       19m
root@brk8sm101:~#
```

