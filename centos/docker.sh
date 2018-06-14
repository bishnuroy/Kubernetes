#!/bin/bash
#This script is created for docker-ce stable version.
Remove old version of docker
#
yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

#
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
#
#Install repo 
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
#remove selinux old version
yum remove container-selinux*

#Install updated selinux (minimum container-selinux-2.9)
yum install -y ftp://ftp.rediris.es/volumes/sites/centos.org/7.3.1611/extras/x86_64/Packages/container-selinux-2.9-4.el7.noarch.rpm
#
#Dependency service

yum install -y ftp://ftp.icm.edu.pl/vol/rzm6/linux-oracle-repo/OracleLinux/OL7/developer_EPEL/x86_64/pigz-2.3.4-1.el7.x86_64.rpm -y

#Install docker service

yum install docker-ce -y

#Start the services

systemctl enable docker
systemctl start docker

