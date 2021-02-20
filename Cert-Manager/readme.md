
**Ref Doc:**
 - https://cert-manager.io/docs/installation/kubernetes/
 - https://cert-manager.io/docs/installation/upgrading/


**Step1:**
 - Add helm repo
   - helm repo add jetstack https://charts.jetstack.io
```
Bishnus-MacBook-Pro-2:~ bishnuroy$ helm search repo
NAME                           	CHART VERSION	APP VERSION	DESCRIPTION                  
jetstack/cert-manager          	v1.1.0       	v1.1.0     	A Helm chart for cert-manager
jetstack/cert-manager-istio-csr	v0.1.0       	v0.1.0     	A Helm chart for istio-csr   
jetstack/tor-proxy             	0.1.1        	           	A Helm chart for Kubernetes  
nginx-stable/nginx-ingress     	0.8.0        	1.10.0     	NGINX Ingress Controller     
Bishnus-MacBook-Pro-2:~ bishnuroy$
```
- Deploy CertManager with helm chart
  - helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.1.0 --set installCRDs=true --kubeconfig=brk8s01-admin.conf
  - helm upgrade cert-manager jetstack/cert-manager --namespace cert-manager --version v1.1.0 --set installCRDs=true --kubeconfig=brk8s01-admin.conf  (This command is for update)

**Step2:**
- Now you have to Create Secret with your CA file or you can do with selfSigne.
- Referance Document.
  - https://shocksolution.com/2018/12/14/creating-kubernetes-secrets-using-tls-ssl-as-an-example/
  - https://dzone.com/articles/create-a-self-signed-ssl-certificate-using-openssl
  - Create ca.cert and ca.key file by help of this selfsign document
  
**Step3:**
- Create secret.
  - kubectl --kubeconfig=brk8s01-admin.conf -n cert-manager create secret tls ca-cert  --key=ca.key --cert=ca.crt
- Creat issuer with this secret
  - kubectl --kubeconfig=brk8s01-admin.conf -n cert-manager apply -f issuer.yaml
  - With CA (issuer.yaml)
 ```
 apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
   name: ca-issuer
   namespace: cert-manager
spec:
  ca:
    secretName: ca-cert
 
 ```
  - With selfSigned
```
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
  namespace: cert-manager
spec:
  selfSigned: {}
```

- Now create Certificate with issuer.
```
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test-default-cert
  namespace: cert-manager
spec:
  commonName: test
  dnsNames:
  - test.cert-manager.svc.cluster.local
  - "*.brrnd.example.com"
  ipAddresses:
  - LB_IP
  issuerRef:
    kind: Issuer
    name: ca-issuer
  secretName: test-tls
```
- Once you create Certificate with this yaml file it wiil generate "test-tls" secret autometicaly with Issuer
- Now you can use this secret in your ingress.
  
