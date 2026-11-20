variable "name" {
  description = <<-EOT
    Nombre de la cuenta CosmosDB.
    Reglas de Azure: 3-44 chars, solo minúsculas, números y guiones.
    Debe comenzar con una letra. Globalmente único.
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,43}$", var.name))
    error_message = "El nombre debe comenzar con letra minúscula, tener 3-44 chars (minúsculas, números, guiones)."
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

variable "consistency_level" {
  description = "Nivel de consistencia: BoundedStaleness, Eventual, Session, Strong, ConsistentPrefix."
  type        = string
  default     = "Session"

  validation {
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_level)
    error_message = "consistency_level debe ser BoundedStaleness, Eventual, Session, Strong o ConsistentPrefix."
  }
}

variable "tags" {
  description = "Tags a aplicar a la cuenta CosmosDB."
  type        = map(string)
  default     = {}
}
