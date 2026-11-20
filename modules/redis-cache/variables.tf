variable "name" {
  description = <<-EOT
    Nombre del Redis Cache. Reglas de Azure:
    - 1–63 caracteres, letras, números y guiones
    - Globalmente único en Azure
  EOT
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group."
  type        = string
}

variable "location" {
  description = "Región de Azure."
  type        = string
}

variable "capacity" {
  description = "Tamaño del caché. 0 = 250 MB (Basic/Standard), 1 = 1 GB, etc."
  type        = number
  default     = 0
}

variable "family" {
  description = "Familia de SKU: 'C' (Basic/Standard) o 'P' (Premium)."
  type        = string
  default     = "C"

  validation {
    condition     = contains(["C", "P"], var.family)
    error_message = "family debe ser 'C' o 'P'."
  }
}

variable "sku_name" {
  description = "SKU del Redis Cache: Basic, Standard o Premium."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "sku_name debe ser Basic, Standard o Premium."
  }
}

variable "tags" {
  description = "Tags a aplicar al Redis Cache."
  type        = map(string)
  default     = {}
}

# ── Private Endpoint (optional) ───────────────────────────────

variable "enable_private_endpoint" {
  description = "Si true, crea un Private Endpoint. Requiere sku_name = Standard o Premium."
  type        = bool
  default     = false
}

variable "vnet_name" {
  description = "Nombre de la VNet existente donde se creará el Private Endpoint."
  type        = string
  default     = ""
}

variable "pe_subnet_address_prefix" {
  description = "CIDR de la subred del Private Endpoint (debe estar dentro del address space de la VNet)."
  type        = string
  default     = "10.28.2.0/24"
}
