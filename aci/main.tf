# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.74.0"
    }
  }
  backend "azurerm" {}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

locals {
  location = "North Europe"
  name     = "azuredemoap"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}"
  location = local.location
  tags = {
    environment = "demo"
  }
}

resource "azurerm_container_group" "aci" {
  name                = "aci-${local.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = local.name
  os_type             = "Linux"

  container {
    name   = "snake-server"
    image  = "pietervincken/snake-server:0.0.2"
    cpu    = "0.5"
    memory = "0.2"

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  tags = {
    environment = "demo"
  }
}
