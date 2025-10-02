# azure-aks-demo

This is a basic cloud demo. 
It showcases Azure Container instances (ACI) and Azure Kubernetes Service (AKS)

## How it works?

There are 4 demos in total, 2 for ACI and 2 for AKS.
The scripts are expected to be executed in numerical order. 

### .env

A dot-env file is required for this demo to run. Fill it with the following contents: 

``` bash
export location="westeurope" # Location to be used by the demo. Terraform resources might get created outside of this!
export name="xxx" # Name of the prefix for resources created
export subscription="xxx-xxx-xxx-xxx-xxx" # Subscription ID where this demo needs to be deployed
export tenant="xxx-xxx-xxx-xxx-xxx" # Tenant ID used for this demo (needed for some TF configuration)
export ARM_TENANT_ID=$tenant # This is needed to pass the tenant ID to the Terraform setup. 
export ARM_SUBSCRIPTION_ID=$subscription # This is needed to pass the subscription ID to the Terraform setup. 
export TF_VAR_docker_username="xxx" # Needed due to pull limit of docker hub
export TF_VAR_docker_pat="xxx" # Needed due to pull limit of docker hub
```

### 0-prepare.sh

This is a utility script that will create a resource group and storage account to use for the Terraform state. 
It also creates the required files for that information to be passed to the other scripts. 

### 1-apply-aci.sh

This script creates a demo ACI setup. 
It launches a single ACI instance with a Snake game demo. 
After the Terraform changes have been applied, it will automatically launch the resulting ACI link in the default webbrowser.

### 2-apply-aci-votes.sh

This script launches the 2nd ACI demo. 
This demo contains a setup with a Azure Databases for PostgreSQL database, a Key Vault and an ACI container PhpPgAdmin. 
After the demo is applied, the browser will launch the website to PhPPgAdmin and the username and password of the database will be shown in the output of the command. 
In this demo, you can show that it's possible to setup a database, connect to if from a service within Azure without exposing it to the public world.

### 3-apply-cluster.sh

This utility script creates an AKS cluster.
It a preparation setup for the 4th script.
Launch this while explaining the use case, as it might take 5-10 minutes to spin up the cluster. 

### 4-deploy-demos.sh

This launches the 2 AKS demos that are available in this repo. 

The first one is a simple hello kubernetes application. 
This demo can be used to show how Kubernetes works (through k9s). 
Scaling out the hello-world application clearly shows that multiple pods are used (Tip: use CURL if the session is sticky in Chrome or Safari)
Restarting the service is another good demo. 

The second demo shows that Kubernetes can also be used for complex workloads with a lot of different components. 
This demo uses a version of the Google Microservices demo. 

After deploying the applications, a browser will automatically be opened towards both demos. 

### 99-terraform-destroy.sh

This is a utility cleanup script. 
It cleans up both the cluster and the aci demo.
**All data in the database or cluster WILL BE LOST when executing this**

### 100-destroy.sh

This final utility script is the inverse of the first `0-prepare.sh` script. 
It removes the storage account and resource group used for storing the Terraform state.