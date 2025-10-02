resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = local.location
  tags = merge(local.common_tags, {
  })
}
