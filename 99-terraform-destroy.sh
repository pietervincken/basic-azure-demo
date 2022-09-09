#!/bin/bash

cd aci-postgres
terraform init -backend-config=config.azurerm.tfbackend
terraform destroy -auto-approve
cd ..

cd cluster
terraform init -backend-config=config.azurerm.tfbackend
terraform destroy -auto-approve
cd ..