variable "name" {
  description = "Nombre del cluster AKS (también se usa como dns_prefix)."
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

variable "node_count" {
  description = "Número de nodos del node pool de sistema."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Tamaño de VM de los nodos. Si falla por cuota, usar Standard_D2s_v3."
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Tags a aplicar al cluster."
  type        = map(string)
  default     = {}
}
