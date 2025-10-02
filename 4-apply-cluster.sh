#!/bin/bash
set -e

cd cluster
tofu init -backend-config=config.azurerm.tfbackend -upgrade
tofu apply -auto-approve -var docker_username=$docker_username -var docker_pat=$docker_pat -var email=$email
tofu output -json > output.json
cd ..