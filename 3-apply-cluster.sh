#!/bin/bash
set -e

cd cluster
terraform init -backend-config=config.azurerm.tfbackend
terraform apply -auto-approve
terraform output -json > output.json
cd ..