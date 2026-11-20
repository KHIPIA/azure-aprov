output "vault_id" {
  description = "ID del recurso Key Vault."
  value       = azurerm_key_vault.this.id
}

output "vault_uri" {
  description = "URI del Key Vault (https://<nombre>.vault.azure.net/)."
  value       = azurerm_key_vault.this.vault_uri
}

output "vault_name" {
  description = "Nombre del Key Vault creado."
  value       = azurerm_key_vault.this.name
}
