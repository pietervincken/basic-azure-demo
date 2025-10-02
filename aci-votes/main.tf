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
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# # Configure the Azure Active Directory Provider
# provider "azuread" {
# }

# provider "random" {

# }

# provider "http" {

# }

locals {
  location = "West Europe"
  name     = "cgkbasicazuredemo"
  common_tags = {
    Owner       = var.email
    environment = "demo"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}"
  location = local.location
  tags = merge(local.common_tags, {
  })
}

data "azurerm_client_config" "current" {
}

resource "azurerm_container_group" "aci" {
  name                = "aci-${local.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = local.name
  os_type             = "Linux"

  image_registry_credential {
    username = var.docker_username
    password = var.docker_pat
    server = "index.docker.io"
  }

  container {
    name   = "vote"
    image  = "pietervincken/votes-vote:0.0.3"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  container {
    name   = "result"
    image  = "pietervincken/votes-result:0.0.1"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8081
      protocol = "TCP"
    }
  }

  container {
    name   = "worker"
    image  = "pietervincken/votes-worker:0.0.1"
    cpu    = "0.5"
    memory = "1.5"
  }

  container {
    name   = "redis"
    image  = "redis:alpine"
    cpu    = "0.5"
    memory = "1.5"
  }

  container {
    name   = "db"
    image  = "postgres:15-alpine"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "postgres"
    }
  }

  tags = merge(local.common_tags, {
  })
}

data "azuread_user" "user" {
  user_principal_name = var.email
}
