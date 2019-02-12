#!/bin/bash
set -xe

OUTPUT="/vagrant/output"

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.0.0.101 --kubernetes-version v1.13.2

mkdir -pv "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" /home/vagrant/.kube/config

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml"
kubectl apply -f /vagrant/yaml/admin-user.yaml

kubectl -n kube-system describe secret "$(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')" > "$OUTPUT/admin-user-token.txt"
grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d > "$OUTPUT/kubecfg.crt"
grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d > "$OUTPUT/kubecfg.key"
openssl pkcs12 -export -clcerts -inkey "$OUTPUT/kubecfg.key" -in "$OUTPUT/kubecfg.crt" -out "$OUTPUT/kubecfg.p12" -name "kubernetes-client" -password "pass:123456"
echo "Browser import certificate file output/kubecfg.p12"
echo " then visit url: https://10.0.0.101:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

kubeadm token list | head -2 | tail -1 | cut -d" " -f1 > "$OUTPUT/token.txt"
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed -e 's/^.* //' > "$OUTPUT/ca-cert-hash.txt"

# Install helm
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
kubectl --namespace kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller --wait
helm version

# Install jupyterhub
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
helm upgrade --install jhub jupyterhub/jupyterhub --namespace jhub --version=0.8.0-beta.1 --values /vagrant/yaml/z2jh-config.yaml
