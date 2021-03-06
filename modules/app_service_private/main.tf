terraform {
  required_version = ">=0.14.9"

  required_providers {
    azurerm = "=2.66.0"
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

resource "azurerm_app_service" "app_service" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = var.app_service_plan_id
  https_only          = true

  site_config {
    scm_type                 = "VSTSRM"
    always_on                = true
    ftps_state               = "AllAllowed"
    dotnet_framework_version = var.dotnet_framework_version
    websockets_enabled       = var.websockets_enabled
    linux_fx_version         = var.linux_fx_version
    min_tls_version          = var.min_tls_version
    health_check_path        = var.health_check_path
  }

  app_settings = var.app_settings

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_app_service.app_service.id
  subnet_id      = var.integration_subnet_id
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_subnet_id

  private_service_connection {
    name                           = var.private_service_connection_name
    is_manual_connection           = false
    private_connection_resource_id = azurerm_app_service.app_service.id
    subresource_names              = ["sites"]
  }

  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

resource "azurerm_app_service_custom_hostname_binding" "custom_domain" {
  for_each            = toset(var.custom_domains)
  hostname            = each.value
  app_service_name    = azurerm_app_service.app_service.name
  resource_group_name = var.resource_group_name
}
