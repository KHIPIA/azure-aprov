##############################################################
# modules/acr/main.tf
#
# Módulo reutilizable: Azure Container Registry (ACR)
# Registro privado de imágenes Docker. Usuario admin
# deshabilitado: el acceso se otorga vía RBAC (ej. AcrPull).
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

resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  # Seguridad: requerido por azure_acr_secure.rego
  admin_enabled = false   # sin credenciales compartidas, solo RBAC

  tags = var.tags
}
