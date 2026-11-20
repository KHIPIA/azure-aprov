# policy/azure_keyvault_secure.rego
#
# Política: los Key Vaults deben cumplir estándares de seguridad.
# Valida:
#   1. enable_rbac_authorization = true   (RBAC moderno, no access policies)
#   2. soft_delete_retention_days >= 7    (ventana de recuperación ante borrado accidental)
#
# Ejecutar: conftest test plan.json -p policy/azure_keyvault_secure.rego

package main

import rego.v1

key_vaults := [r |
  r := input.resource_changes[_]
  r.type == "azurerm_key_vault"
  r.change.actions[_] in {"create", "update"}
]

# deny: RBAC no habilitado (usa access policies legacy en su lugar)
deny contains msg if {
  kv := key_vaults[_]
  not object.get(kv.change.after, "enable_rbac_authorization", false)
  msg := sprintf(
    "❌ [keyvault_secure] '%s' debe tener enable_rbac_authorization = true (RBAC requerido, no access policies).",
    [kv.address]
  )
}

# deny: soft delete insuficiente (< 7 días)
deny contains msg if {
  kv := key_vaults[_]
  days := object.get(kv.change.after, "soft_delete_retention_days", 0)
  days < 7
  msg := sprintf(
    "❌ [keyvault_secure] '%s' tiene soft_delete_retention_days = %d. Se requieren al menos 7 días.",
    [kv.address, days]
  )
}
