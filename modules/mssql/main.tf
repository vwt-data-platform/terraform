terraform {
  required_version = ">=0.13.5"

  required_providers {
    azurerm = "=2.41.0"
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "sql_admin_user_secret" {
  name         = var.sql_admin_user_secret_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "sql_admin_password_secret" {
  name         = var.sql_admin_password_secret_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_mssql_server" "sql_server" {
  name                          = var.sql_server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.sql_server_version
  administrator_login           = data.azurerm_key_vault_secret.sql_admin_user_secret.value
  administrator_login_password  = data.azurerm_key_vault_secret.sql_admin_password_secret.value
  public_network_access_enabled = var.public_network_access_enabled

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_mssql_database" "sql_database" {
  name                        = var.sql_database_name
  server_id                   = azurerm_mssql_server.sql_server.id
  sku_name                    = var.sql_database_sku
  min_capacity                = var.sql_database_min_capacity
  auto_pause_delay_in_minutes = var.sql_database_auto_pause_delay

  short_term_retention_policy {
    retention_days = var.short_term_retention_days
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_mssql_database_extended_auditing_policy" "audit_logging" {
  database_id                             = azurerm_mssql_database.sql_database.id
  storage_endpoint                        = var.audit_logging_primary_blob_endpoint
  storage_account_access_key              = var.audit_logging_primary_access_key
  storage_account_access_key_is_secondary = var.audit_logging_primary_access_key_is_secondary
  retention_in_days                       = var.audit_logging_retention
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "${azurerm_mssql_server.sql_server.name}-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${azurerm_mssql_server.sql_server.name}-connection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = [
      "sqlServer"]
    is_manual_connection           = false
  }
  dynamic private_dns_zone_group {
    for_each = var.private_dns_zone_group
    content {
      name                 = private_dns_zone_group.value["name"]
      private_dns_zone_ids = private_dns_zone_group.value["private_dns_zone_ids"]
    }
  }
}
