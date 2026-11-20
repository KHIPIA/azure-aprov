output "cosmosdb_id" {
  description = "ID del recurso CosmosDB Account."
  value       = azurerm_cosmosdb_account.this.id
}

output "cosmosdb_name" {
  description = "Nombre de la cuenta CosmosDB creada."
  value       = azurerm_cosmosdb_account.this.name
}

output "cosmosdb_endpoint" {
  description = "Endpoint de la cuenta CosmosDB (SQL API)."
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "cosmosdb_primary_key" {
  description = "Clave primaria de la cuenta CosmosDB."
  value       = azurerm_cosmosdb_account.this.primary_key
  sensitive   = true
}

output "cosmosdb_connection_strings" {
  description = "Cadenas de conexión de la cuenta CosmosDB."
  value       = azurerm_cosmosdb_account.this.connection_strings
  sensitive   = true
}
