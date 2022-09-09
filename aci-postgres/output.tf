output "aci_fqdn" {
    value = azurerm_container_group.aci.fqdn
}

output "aci_ip_address" {
    value = azurerm_container_group.aci.ip_address
}

output "pg_secret_id"{
    value = azurerm_key_vault_secret.pgadmin.id
}

output "pg_username"{
    value = azurerm_postgresql_server.database.administrator_login
}

output "pg_name"{
    value= azurerm_postgresql_server.database.name
}