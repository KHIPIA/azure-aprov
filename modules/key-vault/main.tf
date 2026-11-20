##############################################################
# modules/key-vault/main.tf
#
# Módulo reutilizable: Azure Key Vault
# Almacena secretos de la aplicación con acceso RBAC y
# retención de 7 días (soft delete) para recuperación.
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

resource "azurerm_key_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  # Seguridad: requerido por azure_keyvault_secure.rego
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = false   # false para poder destruir en el lab
  enable_rbac_authorization   = true    # RBAC moderno en lugar de access policies

  tags = var.tags
}
