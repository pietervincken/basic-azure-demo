# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.46.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=3.6.0"
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
  common_tags = {
    created-by = var.email
    project    = local.name
  }

  location = "West Europe"
  name     = "cgkpieteraksdemo"
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
  kubernetes_version  = "1.31.2"
  sku_tier = "Standard"

  default_node_pool {
    zones               = [2]
    node_count          = 3
    vm_size             = "standard_b2s"
    name                = "default"
    os_sku              = "Ubuntu"
    auto_scaling_enabled = true
    max_count = 10
    min_count = 3
  }

  azure_active_directory_role_based_access_control {
    # managed = true
    azure_rbac_enabled = true
    admin_group_object_ids = [ data.azuread_user.user.object_id ]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags

}

data "azuread_user" "user" {
  user_principal_name = var.email
}