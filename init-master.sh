#!/bin/bash
set -xe

sudo kubeadm init --pod-network-cidr=10.0.0.0/24 --apiserver-advertise-address=10.0.0.101 --kubernetes-version v1.13.2

mkdir -pv "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" /home/vagrant/.kube/config

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml"

grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d > /vagrant/kubecfg.crt
grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d > /vagrant/kubecfg.key
openssl pkcs12 -export -clcerts -inkey /vagrant/kubecfg.key -in /vagrant/kubecfg.crt -out /vagrant/kubecfg.p12 -name "kubernetes-client" -password "pass:"
echo "Browser import certificate file kubecfg.p12"
echo " then visit url: https://10.0.0.101:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

kubeadm token list | head -2 | tail -1 | cut -d" " -f1 > /vagrant/token.txt
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed -e 's/^.* //' > /vagrant/ca-cert-hash.txt

