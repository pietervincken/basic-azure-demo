# resource "azurerm_redis_cache" "this" {
#   name                = "redis${local.name}"
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name

#   capacity            = 0
#   family              = "C"
#   sku_name            = "Basic"

#   non_ssl_port_enabled = false
  
#   access_keys_authentication_enabled = true

#   # authentication_enabled = false
#   # redis_configuration {
#   #   active_directory_authentication_enabled = true
#   # }

#   tags = merge(local.common_tags, {
#   })
# }

# resource "azurerm_redis_firewall_rule" "this" {
#   name                = "allow_azure_services"
#   redis_cache_name    = azurerm_redis_cache.this.name
#   resource_group_name = azurerm_resource_group.this.name
#   start_ip            = "0.0.0.0"
#   end_ip              = "0.0.0.0"
# }

