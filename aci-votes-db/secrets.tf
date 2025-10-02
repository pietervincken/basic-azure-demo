resource "random_password" "pg_password" {
  length      = 16
  special     = false
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
}

resource "random_password" "pg_username" {
  length    = 16
  special   = false
  upper     = false
  numeric   = false
  min_lower = 1
}