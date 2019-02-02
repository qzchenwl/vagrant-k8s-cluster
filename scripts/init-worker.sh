#!/bin/bash

set -xe

OUTPUT="/vagrant/output"

token="$(cat "$OUTPUT/token.txt")"
hash="$(cat "$OUTPUT/ca-cert-hash.txt")"

sudo kubeadm join 10.0.0.101:6443 --token "$token" --discovery-token-ca-cert-hash "sha256:$hash"

