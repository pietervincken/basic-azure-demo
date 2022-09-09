#!/bin/bash
set -e

cd aci
terraform init -backend-config=config.azurerm.tfbackend
terraform apply -auto-approve
terraform output -json > output.json

fqdn=$(cat output.json| jq --raw-output '.aci_fqdn.value')

if [ -z $fqdn ]; then
    echo "Could not find fqdn. Stopping!"
    exit 1
fi

ip=$(cat output.json| jq --raw-output '.aci_ip_address.value')

if [ -z $ip ]; then
    echo "Could not find ip. Stopping!"
    exit 1
fi

echo "\nFQDN: "
echo "http://$fqdn:8080\n"

echo "IP: "
echo "http://$ip:8080\n"

open http://$fqdn:8080
open http://$ip:8080

cd ..