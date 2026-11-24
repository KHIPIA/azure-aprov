variable "name" {
  description = <<-EOT
    Nombre del Container Registry. Reglas de Azure:
    - 5–50 caracteres, solo letras y números (sin guiones)
    - Globalmente único en Azure
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "El nombre del ACR debe tener 5–50 caracteres alfanuméricos (sin guiones)."
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

variable "sku" {
  description = "SKU del ACR: Basic, Standard o Premium. La política OPA solo permite Basic o Standard."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku debe ser Basic, Standard o Premium."
  }
}

variable "tags" {
  description = "Tags a aplicar al Container Registry."
  type        = map(string)
  default     = {}
}
