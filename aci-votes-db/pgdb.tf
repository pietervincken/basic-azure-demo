resource "azurerm_postgresql_flexible_server" "this" {
  name                          = "pg-${local.name}"
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  version                       = "17"
  public_network_access_enabled = true

  auto_grow_enabled = false

  authentication {
    password_auth_enabled = true
  }

  administrator_login    = random_password.pg_username.result
  administrator_password = random_password.pg_password.result

  sku_name = "B_Standard_B1ms"


  tags = merge(local.common_tags, {
  })

  lifecycle {
    ignore_changes = [
      zone,
    ]
  }

}

resource "azurerm_postgresql_flexible_server_firewall_rule" "pg_fw_allow_azure_services" {
  name             = "allow_azure_services"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_database" "votes_db" {
  name      = "votes"
  server_id = azurerm_postgresql_flexible_server.this.id
}