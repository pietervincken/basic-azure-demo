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

instance_name=$(cat output.json| jq --raw-output '.pg_name.value')

if [ -z $instance_name ]; then
    echo "Could not find name. Stopping!"
    exit 1
fi

db_fqdn=$(cat output.json| jq --raw-output '.pg_fqdn.value')

if [ -z $db_fqdn ]; then
    echo "Could not find fqdn. Stopping!"
    exit 1
fi

db_name=$(cat output.json| jq --raw-output '.pg_db_name.value')

if [ -z $db_name ]; then
    echo "Could not find fqdn. Stopping!"
    exit 1
fi

password=$(az keyvault secret show --id $secret_id --query value | jq --raw-output)

# load test data
docker run -it --rm -v $PWD:/app -e PGPASSWORD="$password" bitnami/postgresql:11 psql -f /app/random.sql -h $db_fqdn -U $username@$instance_name -d $db_name

echo "\nFQDN: "
echo "http://$fqdn:8080\n"

echo "IP: "
echo "http://$ip:8080\n"


echo "PostgreSQL \nusername: $username@$instance_name \npassword: $password"

open http://$fqdn:8080
open http://$ip:8080

cd ..