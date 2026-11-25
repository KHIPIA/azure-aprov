##############################################################
# modules/apim/main.tf
#
# Módulo reutilizable: Azure API Management (APIM)
# Aprovisionamiento básico: SKU Consumption por defecto
# (despliegue rápido, pago por uso) e identidad SystemAssigned
# para integrarse luego con Key Vault u otros servicios.
##############################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

resource "azurerm_api_management" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku_name

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
