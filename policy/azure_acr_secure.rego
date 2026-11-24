# policy/azure_acr_secure.rego
#
# Política: los Container Registries deben cumplir estándares de seguridad y costo.
# Valida:
#   1. admin_enabled = false           (sin credenciales compartidas; acceso vía RBAC)
#   2. sku en {"Basic", "Standard"}    (control de costos: Premium no permitido en el lab)
#
# Ejecutar: conftest test plan.json -p policy/azure_acr_secure.rego

package main

import rego.v1

allowed_acr_skus := {"Basic", "Standard"}

container_registries := [r |
  r := input.resource_changes[_]
  r.type == "azurerm_container_registry"
  r.change.actions[_] in {"create", "update"}
]

# deny: usuario admin habilitado
deny contains msg if {
  acr := container_registries[_]
  object.get(acr.change.after, "admin_enabled", false) == true
  msg := sprintf(
    "❌ [acr_secure] '%s' debe tener admin_enabled = false (usar RBAC, p.ej. AcrPull, no credenciales admin).",
    [acr.address]
  )
}

# deny: SKU no permitido
deny contains msg if {
  acr := container_registries[_]
  sku := object.get(acr.change.after, "sku", "")
  not sku in allowed_acr_skus
  msg := sprintf(
    "❌ [acr_secure] '%s' usa el SKU '%s'. SKUs permitidos: %v",
    [acr.address, sku, allowed_acr_skus]
  )
}
