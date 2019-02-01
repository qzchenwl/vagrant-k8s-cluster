#!/bin/bash
set -xe

sudo kubeadm init --pod-network-cidr=10.0.0.0/24 --apiserver-advertise-address=10.0.0.101 --kubernetes-version v1.13.2

mkdir -pv "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" /home/vagrant/.kube/config

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

kubeadm token list | head -2 | tail -1 | cut -d" " -f1 > /vagrant/token.txt
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed -e 's/^.* //' > /vagrant/ca-cert-hash.txt
