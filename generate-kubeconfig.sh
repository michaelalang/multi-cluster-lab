#!/bin/bash

# Set these values by input arguments
#clusterName='east-cluster'
#server='https://<api-server-url>:6443'
#namespace='istio-system'
#serviceAccount='istiod-basic'
#secretName='istiod-basic-token-zrf4d'

if [ $# -eq 0 ]
then
    echo "No arguments passed. Check --help option."
    exit 1
fi

if [ $1 == "--help" ]
then
    # TODO
    exit 0
fi

for i in "$@"
do
case $i in
    -c=*|--cluster-name=*)
    clusterName="${i#*=}"
    shift
    ;;
    -n=*|--namespace=*)
    namespace="${i#*=}"
    shift
    ;;
    -r=*|--revision=*)
    revision="${i#*=}"
    shift
    ;;
    --remote-kubeconfig-path=*)
    remoteKubeconfigPath="${i#*=}"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
done

set -o errexit

serviceAccount="istiod-$revision"
server=$(grep "server:" "$remoteKubeconfigPath" | awk 'NR==1 { print $2 }')
secretName=$(KUBECONFIG="$remoteKubeconfigPath" oc -n "$namespace" get secrets | grep "istiod-$revision-token" | awk '{print $1}')
ca=$(KUBECONFIG="$remoteKubeconfigPath" oc -n "$namespace" get secret "$secretName" -o=jsonpath='{.data.ca\.crt}')
token=$(KUBECONFIG="$remoteKubeconfigPath" oc -n "$namespace" get secret "$secretName" -o=jsonpath='{.data.token}' | base64 --decode)

echo "apiVersion: v1
kind: Config
clusters:
- name: ${clusterName}
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:
- name: ${serviceAccount}@${clusterName}
  context:
    cluster: ${clusterName}
    namespace: ${namespace}
    user: ${serviceAccount}
users:
- name: ${serviceAccount}
  user:
    token: ${token}
current-context: ${serviceAccount}@${clusterName}"
