#!/bin/bash
TOKEN=$1
ADDRESS=$2
PROJECT=$3

export VAULT_TOKEN=$TOKEN
export VAULT_ADDR=$ADDRESS
kubectl create ns $PROJECT
kubectl create serviceaccount vault-auth -n $PROJECT

VAULT_HELM_SECRET_NAME=$(kubectl get secret -n vault | grep  vault-token | awk '{print $1}')
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
TOKEN_REVIEW_JWT=$(kubectl get secret $VAULT_HELM_SECRET_NAME -n vault --output='go-template={{ .data.token }}' | base64 --decode)

vault auth enable -path=kubernetes-$PROJECT kubernetes

vault write auth/kubernetes-$PROJECT/config \
    token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
    kubernetes_host="$KUBE_HOST" \
    kubernetes_ca_cert="$KUBE_CA_CERT" \
    disable_iss_validation=true \
    issuer="https://kubernetes.default.svc.cluster.local"

vault write auth/kubernetes-$PROJECT/role/$PROJECT \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=$PROJECT \
    policies=kubernetes-$PROJECT \
    ttl=24h

vault policy write kubernetes-$PROJECT - <<EOF
path "secret/data/k8s/$PROJECT/*" {
  capabilities = ["read"]
}
EOF
