variable "name" {
  description = <<-EOT
    Nombre del servicio API Management. Reglas de Azure:
    - 1–50 caracteres: letras, números y guiones
    - Debe empezar con letra y terminar con letra o número
    - Globalmente único (<nombre>.azure-api.net)
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z]([a-zA-Z0-9-]{0,48}[a-zA-Z0-9])?$", var.name))
    error_message = "El nombre de APIM debe tener 1–50 caracteres (letras, números, guiones), empezar con letra y terminar con letra o número."
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

variable "publisher_name" {
  description = "Nombre de la organización publicadora de las APIs."
  type        = string
}

variable "publisher_email" {
  description = "Email del publicador (recibe notificaciones del servicio)."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.publisher_email))
    error_message = "publisher_email debe ser un email válido."
  }
}

variable "sku_name" {
  description = "SKU en formato <Tier>_<capacidad>. Consumption_0 (default) despliega en minutos; Developer_1 tarda 30–60 min."
  type        = string
  default     = "Consumption_0"

  validation {
    condition     = can(regex("^(Consumption_0|(Developer|Basic|Standard|Premium)_[0-9]+)$", var.sku_name))
    error_message = "sku_name debe ser Consumption_0 o <Developer|Basic|Standard|Premium>_<n>."
  }
}

variable "tags" {
  description = "Tags a aplicar al servicio API Management."
  type        = map(string)
  default     = {}
}
