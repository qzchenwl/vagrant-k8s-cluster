#!/bin/bash
set -xe

# 0. SYSTEM INFO & CLUSTER ARCH
# CentOS 7
#
#    +------------+                                +-----------+
#    | k8s-node1  |>10.0.0.101 -------- 10.0.0.102<| k8s-node2 |
#    +------------+                                +-----------+
#          v                                             v
#       internet                                      internet
#
# /etc/hosts
# 10.0.0.101 k8s-node1
# 10.0.0.102 k8s-node2
#

cat >> /etc/hosts <<EOF
10.0.0.101 k8s-node1
10.0.0.102 k8s-node2
10.0.0.103 k8s-node3
EOF

swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

# 1. INSTALL DOCKER
# refer: 
#   - [official-doc](https://kubernetes.io/docs/setup/cri/#docker)
#   - [repo-mirrors](https://www.jianshu.com/p/ad3c712e1d95)
#   - [registry-mirrors](https://blog.csdn.net/u010316188/article/details/79865451)

# Install Docker CE
## Set up the repository
### Install required packages.
yum install -y yum-utils device-mapper-persistent-data lvm2

### Add docker repository.
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache

## Install docker ce.
yum install -y docker-ce-18.06.1.ce

## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

### check docker
docker run hello-world

# 2. INSTALL KUBEADM
# refer:
#   - [official-doc](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
#   - [repo-mirrors](https://www.jianshu.com/p/e43f5e848da1)

## config repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

## network issue
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

kubeadm config images pull --kubernetes-version v1.13.2
