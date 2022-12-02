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
  location            = "North Europe"
  name                = "azuredemoap"

  user_email="pieter.vincken@ordina.be"

  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  upn           = "${replace(local.user_email, "@", "_")}#EXT#@${local.tenant_domain}"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}"
  location = local.location
  tags = {
    environment = "demo"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "mykeyvault" {
  name                = "kv${local.name}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  location            = local.location
}

resource "azurerm_key_vault_access_policy" "myaccess" {
  key_vault_id = azurerm_key_vault.mykeyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_user.user.object_id
  secret_permissions = [
    "Delete", "Get", "List", "Set", "Purge"
  ]
}

resource "azurerm_container_group" "aci" {
  name                = "aci-${local.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = local.name
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "bitnami/phppgadmin"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      "DATABASE_ENABLE_EXTRA_LOGIN_SECURITY" = "yes"
      "DATABASE_HOST"                        = azurerm_postgresql_server.database.fqdn
      "DATABASE_SSL_MODE"                    = "require"
      "PHPPGADMIN_URL_PREFIX"                = "demo"
    }

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  tags = {
    environment = "testing"
  }
}

resource "random_password" "password" {
  length      = 16
  special     = false
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
}

resource "azurerm_key_vault_secret" "pgadmin" {
  key_vault_id = azurerm_key_vault.mykeyvault.id
  name         = "pgadmin"
  value        = random_password.password.result
  depends_on = [
    azurerm_key_vault_access_policy.myaccess
  ]
}

resource "azurerm_postgresql_server" "database" {
  name                = "pgs-${local.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = local.name
  administrator_login_password = random_password.password.result

  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 5120

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

}

resource "azurerm_postgresql_firewall_rule" "firewall_postgres" {
  name                = "pgfr-${local.name}"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.database.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_postgresql_database" "database" {
  name                = "apdb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.database.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}


data "azuread_user" "user" {
  user_principal_name = local.upn
}

data "azuread_domains" "aad_domains" {

}