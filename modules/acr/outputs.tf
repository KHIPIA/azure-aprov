output "acr_id" {
  description = "ID del Container Registry (scope para role assignments)."
  value       = azurerm_container_registry.this.id
}

output "acr_name" {
  description = "Nombre del Container Registry."
  value       = azurerm_container_registry.this.name
}

output "acr_login_server" {
  description = "Login server del ACR (ej. <nombre>.azurecr.io)."
  value       = azurerm_container_registry.this.login_server
}
