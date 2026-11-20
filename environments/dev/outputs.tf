output "key_vault_name" {
  description = "Nombre del Key Vault creado."
  value       = module.key_vault.vault_name
}

output "key_vault_uri" {
  description = "URI del Key Vault."
  value       = module.key_vault.vault_uri
}

output "redis_hostname" {
  description = "Hostname del Redis Cache."
  value       = module.redis_cache.redis_hostname
}

output "redis_ssl_port" {
  description = "Puerto SSL del Redis Cache (6380)."
  value       = module.redis_cache.redis_ssl_port
}

output "cosmosdb_name" {
  description = "Nombre de la cuenta CosmosDB creada."
  value       = module.cosmosdb.cosmosdb_name
}

output "cosmosdb_endpoint" {
  description = "Endpoint de la cuenta CosmosDB (SQL API)."
  value       = module.cosmosdb.cosmosdb_endpoint
}

output "resumen" {
  description = "Resumen de los recursos creados por este alumno."
  value = {
    alumno         = var.owner_alias
    resource_group = var.resource_group_name
    region         = var.location
    key_vault      = module.key_vault.vault_name
    redis          = module.redis_cache.redis_hostname
    cosmosdb       = module.cosmosdb.cosmosdb_name
  }
}

output "aks_name" {
  description = "Nombre del cluster AKS."
  value       = module.aks.aks_name
}
