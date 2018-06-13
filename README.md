# Kubernetes

Kubernetes is an open-source container-orchestration system for automating deployment,
scaling and management of containerized applications. It was originally designed by Google 
and is now maintained by the Cloud Native Computing Foundation.

Nearly all applications nowadays need to have answers for things like

- Replication of components
- Auto-scaling
- Load balancing
- Rolling updates
- Logging across components
- Monitoring and health checking
- Service discovery
- Authentication

Google has given a combined solution for that which is Kubernetes, or how it’s shortly called – K8s


### K8S Architecture

![arc-dia](https://github.com/bishnuroy/Kubernetes/blob/master/images/k8s-arc.jpg)

## Glossary

### Pod
Microservices  are tightly coupled forming a group of containers that would typically, in a non-containerized setup run together on one server. This group, the smallest unit that can be scheduled to be deployed through K8s is called a pod. 

This group of containers would share storage, Linux namespaces, cgroups, IP addresses. These are co-located, hence share resources and are always scheduled together.

Pods are not intended to live long. They are created, destroyed and re-created on demand, based on the state of the server and the service itself.

### Service
As pods have a short lifetime, there is not guarantee about the IP address they are served on. This could make the communication of microservices hard. Imagine a typical Frontend communication with Backend services.

Hence K8s has introduced the concept of a service, which is an abstraction on top of a number of pods, typically requiring to run a proxy on top, for other services to communicate with it via a Virtual IP address. This is where you can configure load balancing for your numerous pods and expose them via a service.

## Kubernetes Components

## Master Node

The master node is responsible for the management of Kubernetes cluster. This is the entry point of all administrative tasks. The master node is the one taking care of orchestrating the worker nodes, where the actual services are running.

### API Server
The API server is the entry points for all the REST commands used to control the cluster. It processes the REST requests, validates them, and executes the bound business logic. The result state has to be persisted somewhere, and that brings us to the next component of the master node.

### ETCD Storage
Etcd is a simple, distributed, consistent key-value store. It’s mainly used for shared configuration and service discovery.

### Scheduler
The scheduler has the information regarding resources available on the members of the cluster, as well as the ones required for the configured service to run and hence is able to decide where to deploy a specific service.

### Controller Manager
A controller uses apiserver to watch the shared state of the cluster and makes corrective changes to the current state to change it to the desired one.


### K8S Workflow

![k8s-wf](https://github.com/bishnuroy/Kubernetes/blob/master/images/k8s-wf.jpg)

## Worker node

The pods are run here, so the worker node contains all the necessary services to manage the networking 
between the containers, communicate with the master node, and assign resources to the containers scheduled.

### Docker
Docker runs on each of the worker nodes, and runs the configured pods. It takes care of downloading the images 
and starting the containers.

### Kubelet
Kubletgets the configuration of a pod from the apiserver and ensures that the described containers are up and running. 
This is the worker service that’s responsible for communicating with the master node.It also communicates with etcd, 
to get information about services and write the details about newly created ones.

### kube-proxy
Kube-proxy acts as a network proxy and a load balancer for a service on a single worker node. It takes care of the 
network routing for TCP and UDP packets.

## kubectl

A command line tool to communicate with the API service and send commands to the master node.


## Ingress Controller

Configuring a webserver or loadbalancer is harder than it should be. Most webserver configuration files are very similar. 
There are some applications that have weird little quirks that tend to throw a wrench in things, but for the most part you can 
apply the same logic to them and achieve a desired result.

The Ingress resource embodies this idea, and an Ingress controller is meant to handle all the quirks associated with a specific 
"class" of Ingress. An Ingress Controller is a daemon, deployed as a Kubernetes Pod, that watches the apiserver's /ingresses 
endpoint for updates to the Ingress resources. Its job is to satisfy requests for Ingresses.

![IC](https://github.com/bishnuroy/Kubernetes/blob/master/images/IC.jpg)

