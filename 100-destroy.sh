#!/bin/sh

if [ -z "$subscription" ]; then
    echo "Could not find subscription. Stopping!"
    exit 1
fi

if [ -z "$location" ]; then
    echo "Could not find location. Stopping!"
    exit 1
fi

if [ -z "$name" ]; then
    echo "Could not find name. Stopping!"
    exit 1
fi

rgstate="rg-$name"
sastate="sa$name"

# remove all non-alphanumeric characters from string
sastate=$(echo "$sastate" | tr -cd '[:alnum:]')

echo "rg=$rgstate"
echo "sa=$sastate"

az account set -s "$subscription"
az storage account show --name "$sastate" && az storage account delete -n "$sastate" -g "$rgstate" -y
az group show --name "$rgstate" && az group delete -n "$rgstate" -y