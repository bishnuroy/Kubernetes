#!/bin/bash
set -e
set -o pipefail

read -p "Enter User Name: " USER_NAME
BASE_DIR="/opt/kubernetes/createUserKubeconfig/userkubedir"
TARGET_FOLDER=${BASE_DIR}/${USER_NAME}

echo " "
read -p "Enter Name Space: " NAMESPACE
SVC_NAME=${USER_NAME}-${NAMESPACE}
BASE_DIR2="/opt/kubernetes/createUserKubeconfig/userkubedir/${NAMESPACE}"
TARGET_FOLDER2=${BASE_DIR}/${USER_NAME}
#
echo ""
read -p "Enter Cluster Name: " CLUSTER
echo ""
KUBE_ADMIN_DIR="/opt/kubernetes/kubeconfig"
KUBECFG_FILE_NAME="${CLUSTER}-${SVC_NAME}.conf"
echo ""
ADMIN_CONFIG=${KUBE_ADMIN_DIR}/${CLUSTER}/${CLUSTER}-admin.conf

read -p "Enter Policy Type for-> For-> Basic Admin --> cuser <-- and For normal user --> nuser <-- : " KPOLICY

create_target_folder() {
     if [ -d $TARGET_FOLDER ]; then
        echo "User Derectory $TARGET_FOLDER already exist"
     else
     	echo -n "Creating target directory to hold files in ${TARGET_FOLDER}..."
     	mkdir -p "${TARGET_FOLDER}"
     	printf "${TARGET_FOLDER} folder is Created"
     fi
}
create_namespace() {

     if [ $(kubectl --kubeconfig=${ADMIN_CONFIG}  get namespace |grep ${NAMESPACE} |awk '{print $1}') == $NAMESPACE ]; then
	echo "The Namespace ${NAMESPACE} Already Exist"
     else
     	echo -e "\\nCreating namespace for ${USER_NAM}"
        kubectl --kubeconfig=${ADMIN_CONFIG} create namespace  ${NAMESPACE}
     fi
}
create_service_account() {
    if [[ $(kubectl --kubeconfig=${ADMIN_CONFIG}  -n $NAMESPACE get sa |grep $SVC_NAME |awk '{print $1}') == "$SVC_NAME" ]]; then
    	echo "Service $SVC_NAME account exist in namespace"
    else
    	echo -e "\\nCreating a service account ${SVC_NAME}"
    	kubectl --kubeconfig=${ADMIN_CONFIG} create sa "${SVC_NAME}" --namespace "${NAMESPACE}"
    fi
}

get_secret_name_from_service_account() {
    echo -e "\\nGetting secret of service account ${SVC_NAME} on ${NAMESPACE}"
    SECRET_NAME=$(kubectl --kubeconfig=${ADMIN_CONFIG} get sa "${SVC_NAME}" --namespace="${NAMESPACE}" -o json | jq -r .secrets[].name)
    #SECRET_NAME=$(kubectl --kubeconfig=${ADMIN_CONFIG} get sa "${SVC_NAME}" -o json | jq -r .secrets[].name)
    echo "Secret name: ${SECRET_NAME}"
}

extract_ca_crt_from_secret() {
    	echo -e -n "\\nExtracting ca.crt from secret..."
    	kubectl --kubeconfig=${ADMIN_CONFIG} get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o json | jq \
    	-r '.data["ca.crt"]' | base64 -d > "${TARGET_FOLDER}/ca.crt"
        #kubectl --kubeconfig=${ADMIN_CONFIG} get secret "${SECRET_NAME}" -o json | jq \
        #-r '.data["ca.crt"]' | base64 -D > "${TARGET_FOLDER}/ca.crt"
    	#printf "done"
}

get_user_token_from_secret() {
    echo -e -n "\\nGetting user token from secret..."
    USER_TOKEN=$(kubectl --kubeconfig=${ADMIN_CONFIG} get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o json | jq -r '.data["token"]' | base64 -d)
    #USER_TOKEN=$(kubectl --kubeconfig=${ADMIN_CONFIG} get secret "${SECRET_NAME}" -o json | jq -r '.data["token"]' | base64 -D)
    printf "done"
}

set_kube_config_values() {
    context=$(kubectl --kubeconfig=${ADMIN_CONFIG} config current-context)
    echo -e "\\nSetting current context to: $context"

    CLUSTER_NAME=$(kubectl --kubeconfig=${ADMIN_CONFIG} config get-contexts "$context" | awk '{print $3}' | tail -n 1)
    echo "Cluster name: ${CLUSTER_NAME}"

    ENDPOINT=$(kubectl --kubeconfig=${ADMIN_CONFIG} config view \
    -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}")
    echo "Endpoint: ${ENDPOINT}"

    # Set up the config
    echo -e "\\nPreparing ${KUBECFG_FILE_NAME}"
    echo -n "Setting a cluster entry in kubeconfig..."
    kubectl --kubeconfig=${ADMIN_CONFIG} config set-cluster "${CLUSTER_NAME}" \
    --kubeconfig="${TARGET_FOLDER}/${KUBECFG_FILE_NAME}" \
    --server="${ENDPOINT}" \
    --certificate-authority="${TARGET_FOLDER}/ca.crt" \
    --embed-certs=true

    echo -n "Setting token credentials entry in kubeconfig..."
    kubectl --kubeconfig=${ADMIN_CONFIG} config set-credentials \
    "${SVC_NAME}@${CLUSTER_NAME}" \
    --kubeconfig="${TARGET_FOLDER}/${KUBECFG_FILE_NAME}" \
    --token="${USER_TOKEN}"

    echo -n "Setting a context entry in kubeconfig..."
    kubectl --kubeconfig=${ADMIN_CONFIG} config set-context \
    "${SVC_NAME}@${CLUSTER_NAME}" \
    --kubeconfig="${TARGET_FOLDER}/${KUBECFG_FILE_NAME}" \
    --cluster="${CLUSTER_NAME}" \
    --user="${SVC_NAME}@${CLUSTER_NAME}" \
    --namespace="${NAMESPACE}"

    echo -n "Setting the current-context in the kubeconfig file..."
    kubectl --kubeconfig=${ADMIN_CONFIG} config use-context "${SVC_NAME}@${CLUSTER_NAME}" \
    --kubeconfig="${TARGET_FOLDER}/${KUBECFG_FILE_NAME}"
}
namespace_role() {
echo "Creating RBACK role for ${USER_NAME} user"
echo ""
read -p "Enter access typr ----> For Read only  --> read <-- and For write --> write <-- : " ATYPE
echo ""
if [ "$ATYPE" == "write" ]; then
{  
cat <<EOF | kubectl --kubeconfig=${ADMIN_CONFIG} --namespace=${NAMESPACE} apply -f -
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    name: ${USER_NAME}-role
    namespace: ${NAMESPACE}
  rules:
  - apiGroups:
    - "*"
    resources:
    - pods
    - secrets
    - serviceaccounts
    - persistent-volumes
    verbs:
    - get
    - list
    - create
    - update
    - delete
  - apiGroups:
    - extensions
    resources:
    - deployments
    - ingresses
    verbs:
    - get
    - list
    - create
    - update
    - delete
  - apiGroups:
    - "*"
    resources:
    - "*"
    verbs:
    - "*"
EOF
}

else
{
cat <<EOF | kubectl --kubeconfig=${ADMIN_CONFIG} --namespace=${NAMESPACE} apply -f -
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    name: ${USER_NAME}-role
    namespace: ${NAMESPACE}
  rules:
  - apiGroups:
    - "*"
    resources:
    - pods
    - secrets
    - serviceaccounts
    - persistent-volumes
    verbs:
    - get
    - list
  - apiGroups:
    - extensions
    resources:
    - deployments
    - ingresses
    verbs:
    - get
    - list
EOF
}
fi

echo " "
echo "Creating RBACK rolebinding for ${USER_NAME} user"

cat <<EOF | kubectl --kubeconfig=${ADMIN_CONFIG} --namespace=${NAMESPACE} apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${USER_NAME}-rlb
  namespace: ${NAMESPACE}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ${USER_NAME}-role
subjects:
- kind: ServiceAccount
  name: ${SVC_NAME}
  namespace: ${NAMESPACE}


EOF

}

cluster_role() {
echo "Creating RBACK ClusterRole and ClusterRolebinding for ${USER_NAME}"

cat <<EOF | kubectl --kubeconfig=${ADMIN_CONFIG} apply -f -

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${SVC_NAME}-crlb
subjects:
- kind: ServiceAccount
  name: ${SVC_NAME}
  namespace: ${NAMESPACE}
- kind: User
  name: ${USER_NAME}
roleRef:
  kind: ClusterRole
  name: dedicated-admin
  apiGroup: rbac.authorization.k8s.io

EOF

}

create_user_rbac() {

if [ "$KPOLICY" == "cuser" ]; then
 {
 	cluster_role 
        echo -e "ClusterRole is created"
        
 }

elif [ "$KPOLICY" == "nuser" ]; then
  {
  	namespace_role
        echo -e "userRole is created"
  }

else
  {
 	"By default we are creating admin role policy for ${NAMESPACE} though you are giving wrong input."
  }
fi
}

create_target_folder
create_namespace
create_service_account
get_secret_name_from_service_account
extract_ca_crt_from_secret
get_user_token_from_secret
set_kube_config_values
create_user_rbac

echo -e "\\nAll done! Test with: "
echo "KUBECONFIG=userkubedir/${USER_NAME}/${KUBECFG_FILE_NAME} kubectl get pods"
#ls /opt/kubernetes/createUserKubeconfig/ /opt/kubernetes/kubeconfig
