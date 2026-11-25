output "apim_id" {
  description = "ID del servicio API Management."
  value       = azurerm_api_management.this.id
}

output "apim_name" {
  description = "Nombre del servicio API Management."
  value       = azurerm_api_management.this.name
}

output "apim_gateway_url" {
  description = "URL del gateway de APIM (ej. https://<nombre>.azure-api.net)."
  value       = azurerm_api_management.this.gateway_url
}

output "apim_principal_id" {
  description = "Object ID de la identidad SystemAssigned (para role assignments)."
  value       = azurerm_api_management.this.identity[0].principal_id
}
