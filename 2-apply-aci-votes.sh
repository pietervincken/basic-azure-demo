#!/bin/bash
set -e

if [ -z "$docker_username" ]; then
    echo "Could not find docker_username. Stopping!"
    exit 1
fi

if [ -z "$docker_pat" ]; then
    echo "Could not find docker_pat. Stopping!"
    exit 1
fi

cd aci-votes
tofu init -backend-config=config.azurerm.tfbackend -upgrade
tofu apply -auto-approve -var docker_username=$docker_username -var docker_pat=$docker_pat -var email=$email
tofu output -json > output.json

# if ! docker info > /dev/null 2>&1; then
#   echo "This script uses docker, and it isn't running - please start docker and try again!"
#   exit 1
# fi

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
echo "http://$fqdn:8081\n"

echo "IP: "
echo "http://$ip:8080\n"
echo "http://$ip:8081\n"

open http://$ip:8080
open http://$ip:8081

cd ..