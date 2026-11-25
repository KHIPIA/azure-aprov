# =============================================================
#  terraform.tfvars — Configuración por alumno
#  ⚠️ EDITA SOLO LAS TRES LÍNEAS MARCADAS CON ←
# =============================================================

# ── EDITAR ESTOS VALORES ──────────────────────────────────────
resource_group_name  = "RG-KHIPIA"            # ← Tu RG asignado por el docente
owner_alias          = "khipia"               # ← Tu alias único (2-10 chars, sin espacios)
apim_publisher_email = "tu-email@ejemplo.com"  # ← Email del publisher de APIM
# ─────────────────────────────────────────────────────────────

# Valores comunes para toda la clase (no modificar)
environment      = "dev"
location         = "eastus"
cost_center      = "CC-UTEC-M04"
container_image  = "nginx:alpine"
container_cpu    = 0.25
container_memory = "0.5Gi"
min_replicas     = 1
max_replicas     = 3

/* # Redis Cache — Standard C0 required for Private Endpoint
redis_capacity                = 0
redis_family                  = "C"
redis_sku                     = "Standard"
redis_enable_private_endpoint = true
redis_vnet_name               = "vnet-utec-wilmer"
redis_pe_subnet_prefix        = "10.28.2.0/24" */
