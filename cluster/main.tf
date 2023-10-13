# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.75.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.43.0"
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
  kubernetes_version  = "1.27.3"

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

data "azuread_user" "user" {
  user_principal_name = local.upn
}

data "azuread_domains" "aad_domains" {

}
