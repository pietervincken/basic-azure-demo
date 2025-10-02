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
    random = {
      source  = "hashicorp/random"
      version = "=3.7.2"
    }
  }
  backend "azurerm" {}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Configure the Azure Active Directory Provider
provider "azuread" {
}

provider "random" {

}

locals {
  location = "West Europe"
  name     = "cgkbasicazuredemo"
  common_tags = {
    Owner       = var.email
    environment = "demo"
  }
}

data "azurerm_client_config" "current" {
}

data "azuread_user" "user" {
  user_principal_name = var.email
}