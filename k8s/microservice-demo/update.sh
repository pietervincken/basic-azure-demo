#!/bin/bash


if [ -z $1 ]; then
    version=main
    echo "Didn't find specific version, using main!"
else
    version=$1
    echo "Found version $version"
fi

curl -Ls https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/$version/release/kubernetes-manifests.yaml  -o kustomize/resources/install.yaml