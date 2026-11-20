variable "name" {
  description = <<-EOT
    Nombre del Key Vault. Reglas de Azure:
    - 3–24 caracteres, solo letras, números y guiones
    - Debe comenzar con una letra
    - Globalmente único en Azure
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{2,23}$", var.name))
    error_message = "El nombre debe comenzar con letra, tener 3–24 chars (letras, números, guiones)."
  }
}

variable "resource_group_name" {
  description = "Nombre del Resource Group."
  type        = string
}

variable "location" {
  description = "Región de Azure."
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID de Azure AD. Se obtiene de data.azurerm_client_config.current.tenant_id."
  type        = string
}

variable "soft_delete_retention_days" {
  description = "Días de retención de secretos eliminados (7–90). Requerido >= 7 por la política OPA."
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days debe estar entre 7 y 90."
  }
}

variable "tags" {
  description = "Tags a aplicar al Key Vault."
  type        = map(string)
  default     = {}
}
