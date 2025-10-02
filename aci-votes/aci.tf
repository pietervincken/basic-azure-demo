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
    server   = "index.docker.io"
  }

  container {
    name   = "vote"
    image  = "pietervincken/votes-vote:0.0.5"
    cpu    = "0.5"
    memory = "1.5"

    environment_variables = {
      "REDIS_HOST" = "localhost"
    }

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  container {
    name   = "result"
    image  = "pietervincken/votes-result:0.0.5"
    cpu    = "0.5"
    memory = "1.5"

    environment_variables = {
      "POSTGRES_HOST" = "localhost"
    }

    ports {
      port     = 8081
      protocol = "TCP"
    }
  }

  container {
    name   = "worker"
    image  = "pietervincken/votes-worker:0.0.5"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      "REDIS_HOST"    = "localhost"
      "POSTGRES_HOST" = "localhost"
    }
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
      POSTGRES_USER : "postgres"
      POSTGRES_PASSWORD : "postgres"
    }
  }

  tags = merge(local.common_tags, {
  })
}
