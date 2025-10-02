output "aci_fqdn" {
  value = azurerm_container_group.this.fqdn
}

output "aci_ip_address" {
  value = azurerm_container_group.this.ip_address
}