#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

readonly ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/env.sh

# ensure $RELEASES_DIR is an absolute file path
mkdir -p ${RELEASES_DIR}
RELEASES_DIR=$(cd ${RELEASES_DIR}; pwd)

# get absolute file path of binaries
BINARY_DIR=$(cd ${ROOT}; pwd)/binaries

function clean-up() {
  rm -rf ${RELEASES_DIR}
  rm -rf ${BINARY_DIR}
}

function download-releases() {
  rm -rf ${RELEASES_DIR}
  mkdir -p ${RELEASES_DIR}

  echo "Download flannel release v${FLANNEL_VERSION} ..."
  curl -L ${FLANNEL_DOWNLOAD_URL} -o ${RELEASES_DIR}/flannel.tar.gz

  #echo "Download etcd release v${ETCD_VERSION} ..."
  #curl -L ${ETCD_DOWNLOAD_URL} -o ${RELEASES_DIR}/etcd.tar.gz

  echo "Download kubernetes release v${K8S_VERSION} ..."
  curl -L ${K8S_CLIENT_DOWNLOAD_URL} -o ${RELEASES_DIR}/kubernetes-client-linux-amd64.tar.gz
  curl -L ${K8S_SERVER_DOWNLOAD_URL} -o ${RELEASES_DIR}/kubernetes-server-linux-amd64.tar.gz

  #echo "Download docker release v${DOCKER_VERSION} ..."
  #curl -L ${DOCKER_DOWNLOAD_URL} -o ${RELEASES_DIR}/docker.tar.gz
}

function unpack-releases() {
  rm -rf ${BINARY_DIR}
  mkdir -p ${BINARY_DIR}/master/bin
  mkdir -p ${BINARY_DIR}/node/bin

  # flannel
  if [[ -f ${RELEASES_DIR}/flannel.tar.gz ]] ; then
    tar xzf ${RELEASES_DIR}/flannel.tar.gz -C ${RELEASES_DIR}
    cp ${RELEASES_DIR}/flanneld ${BINARY_DIR}/master/bin
    cp ${RELEASES_DIR}/flanneld ${BINARY_DIR}/node/bin
  fi

  
  # k8s
  if [[ -f ${RELEASES_DIR}/kubernetes-client-linux-amd64.tar.gz ]] ; then
    tar xzf ${RELEASES_DIR}/kubernetes-client-linux-amd64.tar.gz -C ${RELEASES_DIR}
    cp ${RELEASES_DIR}/kubernetes/client/bin/kubectl ${BINARY_DIR}
  fi

  if [[ -f ${RELEASES_DIR}/kubernetes-server-linux-amd64.tar.gz ]] ; then
    tar xzf ${RELEASES_DIR}/kubernetes-server-linux-amd64.tar.gz -C ${RELEASES_DIR}
    cp ${RELEASES_DIR}/kubernetes/server/bin/kube-apiserver \
       ${RELEASES_DIR}/kubernetes/server/bin/kube-controller-manager \
       ${RELEASES_DIR}/kubernetes/server/bin/kube-scheduler ${BINARY_DIR}/master/bin
    cp ${RELEASES_DIR}/kubernetes/server/bin/kubelet \
       ${RELEASES_DIR}/kubernetes/server/bin/kube-proxy ${BINARY_DIR}/node/bin
  fi

  chmod -R +x ${BINARY_DIR}
  echo "Done! All binaries are stored in ${BINARY_DIR}"
}

function parse-opt() {
  local opt=${1-}

  case $opt in
    download)
      download-releases
      ;;
    unpack)
      unpack-releases
      ;;
    clean)
      clean-up
      ;;
    all)
      download-releases
      unpack-releases
      ;;
    *)
      echo "Usage: "
      echo "   build.sh <command>"
      echo "Commands:"
      echo "   clean      Clean up downloaded releases and unpacked binaries."
      echo "   download   Download releases to \"${RELEASES_DIR}\"."
      echo "   unpack     Unpack releases downloaded in \"${RELEASES_DIR}\", and copy binaries to \"${BINARY_DIR}\"."
      echo "   all        Download releases and unpack them."
      ;;
  esac
}

parse-opt $@
