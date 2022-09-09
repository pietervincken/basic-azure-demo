#!/bin/bash

rgruntime=$(cat cluster/output.json| jq --raw-output '.rg_runtime.value')

if [ -z $rgruntime ]; then
    echo "Could not find rgruntime. Stopping!"
    exit 1
fi

clustername=$(cat cluster/output.json| jq --raw-output '.cluster_name.value')

if [ -z $clustername ]; then
    echo "Could not find clustername. Stopping!"
    exit 1
fi

az aks get-credentials -g $rgruntime -n $clustername --admin --overwrite-existing

kubectl apply -k k8s/microservice-demo/kustomize

kubectl apply -k k8s/hello-kubernetes-demo

echo ""

external_ip=""
while [ -z $external_ip ]; do
  echo "Waiting for hello-kubernetes end point..."
  external_ip=$(kubectl get svc -n hello-kubernetes hello-kubernetes-hello-world --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
  [ -z "$external_ip" ] && sleep 10
done
helloworldIP=$external_ip

echo "\nHello-kubernetes demo is ready!"
echo "http://$helloworldIP"
echo "watch -n 1 curl http://$helloworldIP\n"
open http://$helloworldIP

external_ip=""
while [ -z $external_ip ]; do
  echo "Waiting for microservice-demo end point..."
  external_ip=$(kubectl get svc -n microservice-demo frontend-external --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
  [ -z "$external_ip" ] && sleep 10
done
microserviceIP=$external_ip

echo "\nMicroservice demo is ready!"
echo "http://$microserviceIP"
open http://$microserviceIP