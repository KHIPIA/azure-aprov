output "redis_id" {
  description = "ID del recurso Redis Cache."
  value       = azurerm_redis_cache.this.id
}

output "redis_hostname" {
  description = "Hostname del Redis Cache."
  value       = azurerm_redis_cache.this.hostname
}

output "redis_ssl_port" {
  description = "Puerto SSL del Redis Cache (6380)."
  value       = azurerm_redis_cache.this.ssl_port
}

output "redis_name" {
  description = "Nombre del Redis Cache creado."
  value       = azurerm_redis_cache.this.name
}

output "redis_primary_connection_string" {
  description = "Cadena de conexión primaria (incluye access key). Usar con precaución."
  value       = azurerm_redis_cache.this.primary_connection_string
  sensitive   = true
}

output "private_endpoint_id" {
  description = "ID del Private Endpoint. Null si enable_private_endpoint = false."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.redis[0].id : null
}

output "private_endpoint_ip" {
  description = "IP privada del Private Endpoint. Null si enable_private_endpoint = false."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.redis[0].private_service_connection[0].private_ip_address : null
}

output "vnet_id" {
  description = "ID de la VNet usada para el Private Endpoint. Null si enable_private_endpoint = false."
  value       = var.enable_private_endpoint ? data.azurerm_virtual_network.existing[0].id : null
}
