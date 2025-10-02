#!/bin/bash

cd aci-votes
tofu init -backend-config=config.azurerm.tfbackend
tofu destroy -auto-approve -var docker_username=$docker_username -var docker_pat=$docker_pat -var email=$email
cd ..

cd cluster
tofu init -backend-config=config.azurerm.tfbackend
tofu destroy -auto-approve -var docker_username=$docker_username -var docker_pat=$docker_pat -var email=$email
cd ..