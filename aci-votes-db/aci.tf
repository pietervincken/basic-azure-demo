
resource "azurerm_container_group" "this" {
  name                = "aci-${local.name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "Public"
  dns_name_label      = local.name
  os_type             = "Linux"

  image_registry_credential {
    username = var.docker_username
    password = var.docker_pat
    server   = "index.docker.io"
  }

  container {
    name   = "vote"
    image  = "pietervincken/votes-vote:0.0.9"
    cpu    = "0.5"
    memory = "1.5"

    environment_variables = {
      "REDIS_HOST"        = "localhost"
    }

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  container {
    name   = "result"
    image  = "pietervincken/votes-result:0.0.7"
    cpu    = "0.5"
    memory = "1.5"

    environment_variables = {
      "POSTGRES_HOST"     = azurerm_postgresql_flexible_server.this.fqdn
      "POSTGRES_USER"     = random_password.pg_username.result
      "POSTGRES_PASSWORD" = random_password.pg_password.result
      "POSTGRES_DB"       = azurerm_postgresql_flexible_server_database.votes_db.name
    }

    ports {
      port     = 8081
      protocol = "TCP"
    }
  }

  container {
    name   = "worker"
    image  = "pietervincken/votes-worker:0.0.9"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      "REDIS_CONNECTIONSTRING"        = "localhost"
      "POSTGRES_HOST"     = azurerm_postgresql_flexible_server.this.fqdn
      "POSTGRES_USER"     = random_password.pg_username.result
      "POSTGRES_PASSWORD" = random_password.pg_password.result
      "POSTGRES_DB"       = azurerm_postgresql_flexible_server_database.votes_db.name
    }
  }

  container {
    name   = "redis"
    image  = "redis:alpine"
    cpu    = "0.5"
    memory = "1.5"
  }

  tags = merge(local.common_tags, {
  })
}