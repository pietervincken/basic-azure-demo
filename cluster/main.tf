# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.21.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.28.1"
    }
  }
  backend "azurerm" {}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Configure the Azure Active Directory Provider
provider "azuread" {
}

locals {
  user_email = "pieter.vincken@ordina.be"

  common_tags = {
    created-by = local.user_email
    project    = local.name
  }

  location = "West Europe"
  name     = "aksdemoap"

  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  upn           = "${replace(local.user_email, "@", "_")}#EXT#@${local.tenant_domain}"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}"
  location = local.location
  tags     = local.common_tags
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${local.name}-k8s"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = local.name
  kubernetes_version  = "1.24.3"

  default_node_pool {
    zones               = [3]
    node_count          = 3
    enable_auto_scaling = false
    vm_size             = "standard_b2s"
    name                = "default"
    os_sku              = "Ubuntu"
  }

  azure_active_directory_role_based_access_control {
    managed = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags

}

resource "azurerm_container_registry" "acr" {
  name                = "acr${local.name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  tags                = local.common_tags
  sku                 = "Basic"
}

resource "azurerm_role_assignment" "aksacr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "aks" {
  scope                = azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = data.azuread_user.user.object_id
}

data "azuread_user" "user" {
  user_principal_name = local.upn
}

data "azuread_domains" "aad_domains" {

}
