resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}"
  location = local.location
  tags = merge(local.common_tags, {
  })
}
