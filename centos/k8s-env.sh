#!/usr/bin/env bash

## Contains configuration values for the Binaries downloading and unpacking.

# Directory to store release packages that will be downloaded.
RELEASES_DIR=${RELEASES_DIR:-/scripts/downloads}
#BINARY_DIR=${BINARY_DIR:-/opt/kubernetes/bin}

# Define flannel version to use.
FLANNEL_VERSION=${FLANNEL_VERSION:-"0.10.0"}

# Define k8s version to use.
K8S_VERSION=${K8S_VERSION:-"1.10.4"}

FLANNEL_DOWNLOAD_URL=\
"https://github.com/coreos/flannel/releases/download/v${FLANNEL_VERSION}/flannel-v${FLANNEL_VERSION}-linux-amd64.tar.gz"

K8S_CLIENT_DOWNLOAD_URL=\
"https://dl.k8s.io/v${K8S_VERSION}/kubernetes-client-linux-amd64.tar.gz"
K8S_SERVER_DOWNLOAD_URL=\
"https://dl.k8s.io/v${K8S_VERSION}/kubernetes-server-linux-amd64.tar.gz"
