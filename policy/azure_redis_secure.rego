# policy/azure_redis_secure.rego
#
# Política: los Redis Cache deben cumplir estándares de seguridad.
# Valida:
#   1. enable_non_ssl_port = false   (deshabilita puerto 6379 sin cifrado)
#   2. minimum_tls_version = "1.2"   (fuerza TLS 1.2 en puerto 6380)
#
# Ejecutar: conftest test plan.json -p policy/azure_redis_secure.rego

package main

import rego.v1

redis_caches := [r |
  r := input.resource_changes[_]
  r.type == "azurerm_redis_cache"
  r.change.actions[_] in {"create", "update"}
]

# deny: puerto no-SSL habilitado (6379, sin cifrado)
deny contains msg if {
  rc := redis_caches[_]
  object.get(rc.change.after, "enable_non_ssl_port", false) == true
  msg := sprintf(
    "❌ [redis_secure] '%s' tiene el puerto no-SSL (6379) habilitado. Establece enable_non_ssl_port = false.",
    [rc.address]
  )
}

# deny: versión TLS menor a 1.2
deny contains msg if {
  rc := redis_caches[_]
  tls := object.get(rc.change.after, "minimum_tls_version", "1.0")
  tls != "1.2"
  msg := sprintf(
    "❌ [redis_secure] '%s' usa minimum_tls_version = '%s'. Se requiere '1.2'.",
    [rc.address, tls]
  )
}
