
## Ingress Controller

Configuring a webserver or loadbalancer is harder than it should be. Most webserver configuration files are very similar. 
There are some applications that have weird little quirks that tend to throw a wrench in things, but for the most part you can 
apply the same logic to them and achieve a desired result.

The Ingress resource embodies this idea, and an Ingress controller is meant to handle all the quirks associated with a specific 
"class" of Ingress. An Ingress Controller is a daemon, deployed as a Kubernetes Pod, that watches the apiserver's /ingresses 
endpoint for updates to the Ingress resources. Its job is to satisfy requests for Ingresses.

![IC](https://github.com/bishnuroy/Kubernetes/blob/master/images/IC.jpg)


## Ingress Controller Setup:

### Deploy nginx a a service:

Create ingress-controller.service file with below contents.

```service
[Unit]
Description=kubernetes ingress controller
Requires=docker.service
After=docker.service
[Service]
Environment="POD_NAME=nginx-ingress-controller"
Environment="POD_NAMESPACE=kube-system"
Environment="TCPUDP_NAMESPACE=kube-ingress"
Environment="INGRESS_IMG=quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.19.0"
Environment="K8S_API=https://API_SERVER_FQDN:6443"
Environment="KUB_CONF=/opt/kubernetes/ssl/ingress.kubeconfig"
Environment="WILD_CARD_SECRET_NAME=Give Wild Card Secret Name As Per Your Setup"
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill nginx-ingress-controller
ExecStartPre=-/usr/bin/docker rm nginx-ingress-controller
ExecStartPre=/usr/bin/docker pull ${INGRESS_IMG}
ExecStart=/usr/bin/docker run -t --name nginx-ingress-controller --net=host \
  -v /opt/kubernetes/ssl:/opt/kubernetes/ssl \
  -e K8S_API=${K8S_API} \
  -e POD_NAME=${POD_NAME} -e POD_NAMESPACE=${POD_NAMESPACE} \
  -e TCPUDP_NAMESPACE=${TCPUDP_NAMESPACE} ${INGRESS_IMG} /nginx-ingress-controller \
  --default-backend-service=${POD_NAMESPACE}/default-http-backend --apiserver-host=${K8S_API} \
  --kubeconfig=${KUB_CONF} \
  --election-id=ingress-controller-leader-internal \
  --default-ssl-certificate=${POD_NAMESPACE}/${WILD_CARD_SECRET_NAME} \
  --udp-services-configmap=${TCPUDP_NAMESPACE}/ingress-udp \
  --tcp-services-configmap=${TCPUDP_NAMESPACE}/ingress-tcp
ExecStop=/usr/bin/docker stop nginx-ingress-controller

Restart=on-failure
[Install]
WantedBy=multi-user.target

```

### Before start ingress-controller.servive create "/opt/kubernetes/ssl/ingress.kubeconfig" file with below configuration.
  - change "KUBE_API_SERVER_FQDN" with api FQDN.
  - Copy client certs(ca.pem, client.pem and client-key.pem) on "/opt/kubernetes/ssl/" this path.
```
apiVersion: v1
clusters:
- cluster:
    certificate-authority: "/opt/kubernetes/ssl/ca.pem"
    server: https://KUBE_API_SERVER_FQDN:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: ingress
  name: ingress-to-kubernetes
current-context: ingress-to-kubernetes
kind: Config
preferences: {}
users:
- name: ingress
  user:
    client-certificate: "/opt/kubernetes/ssl/client.pem"
    client-key: "/opt/kubernetes/ssl/client-key.pem"
```

systemctl enable ingress-controller
systemctl start ingress-controller
systemctl status ingress-controller


After deployed Ingress controller service below yaml file have to be deployed in k8s cluster.

1. "[default-http-backend.yaml](https://github.com/bishnuroy/Kubernetes/blob/master/centos/Ingress%20controller/default-http-backend.yaml)" in "kube-system" namespace.

2. "ingress-tcp.yaml" in "[kube-ingress](https://github.com/bishnuroy/Kubernetes/blob/master/centos/Ingress%20controller/ingress-tcp.yaml)" namespace

3. "[ingress-udp.yaml](https://github.com/bishnuroy/Kubernetes/blob/master/centos/Ingress%20controller/ingress-udp.yaml)" in "kube-ingress" namespace

4. "[wildcard-secret.yaml](https://github.com/bishnuroy/Kubernetes/blob/master/centos/Ingress%20controller/wildcard-secret.yaml)" in "kube-ingress" namespace



## Inginx Setup as a deployment for this setup you will be need a loadbalancer like Nginx, HAProxy.

### Step1:
   
   - Deploy [ingress-deployment.yaml](https://github.com/bishnuroy/Kubernetes/blob/master/centos/Ingress%20controller/ingress-deployment.yaml) in your cluster.
   
```console
   kubectl --kubeconfig=kubeconfig_file -n ingress-nginx create -f ngress-deployment.yaml
```

Check the pod and service status, In this deployment I have exposed nodePort "30080" and "30443"

### Step2:

 - Add all the worker node in loadbalancer with "30080" and "30443" port.
 
 



   



