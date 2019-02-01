#!/bin/bash

set -x

token="$(cat /vagrant/token.txt)"
hash="$(cat /vagrant/ca-cert-hash.txt)"

sudo kubeadm join 10.0.0.101:6443 --token "$token" --discovery-token-ca-cert-hash "sha256:$hash"

