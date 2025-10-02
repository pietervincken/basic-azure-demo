#!/bin/bash
set -e

cd cluster
tofu init -backend-config=config.azurerm.tfbackend -upgrade
tofu apply -auto-approve
tofu output -json > output.json
cd ..