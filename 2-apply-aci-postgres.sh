#!/bin/bash
set -e

cd aci-postgres
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

secret_id=$(cat output.json| jq --raw-output '.pg_secret_id.value')

if [ -z $secret_id ]; then
    echo "Could not find secret_id. Stopping!"
    exit 1
fi

username=$(cat output.json| jq --raw-output '.pg_username.value')

if [ -z $username ]; then
    echo "Could not find username. Stopping!"
    exit 1
fi

name=$(cat output.json| jq --raw-output '.pg_name.value')

if [ -z $name ]; then
    echo "Could not find name. Stopping!"
    exit 1
fi

echo "\nFQDN: "
echo "http://$fqdn:8080\n"

echo "IP: "
echo "http://$ip:8080\n"

password=$(az keyvault secret show --id $secret_id --query value)

echo "PostgreSQL \nusername: $username@$name \npassword: $password"


open http://$fqdn:8080
open http://$ip:8080

cd ..