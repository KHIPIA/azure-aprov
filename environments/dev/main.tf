##############################################################
# environments/dev/main.tf
#
# Entorno "dev": orquesta los seis módulos del laboratorio.
#
# Composición de módulos:
#   log_analytics → container_apps  (workspace_id como input)
#   log_analytics → app_insights    (workspace_id como input)
#   storage       → container_apps  (storage_account_name como input)
##############################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

# Tenant ID del usuario autenticado — requerido por el módulo Key Vault
data "azurerm_client_config" "current" {}

# ── Locals ────────────────────────────────────────────────────
locals {
  # Sufijo único por alumno: alias + entorno
  suffix = "${var.owner_alias}-${var.environment}"

  # Nombre del Storage Account: solo minúsculas y números, max 24 chars
  # "st" + alias (max 10) + env (3) + hash (6) = max 21 chars
  storage_name = "st${replace(substr(var.owner_alias, 0, 10), "-", "")}${substr(var.environment, 0, 3)}${substr(md5(var.resource_group_name), 0, 6)}"

  # Nombre del Key Vault: empieza con letra, max 24 chars, globalmente único
  # "kv-" (3) + alias (max 8) + "-" + env (max 3) + "-" + hash (5) = max 21 chars
  keyvault_name = "kv-${substr(var.owner_alias, 0, 8)}-${substr(var.environment, 0, 3)}-${substr(md5(var.resource_group_name), 0, 5)}"

  # Tags comunes — la política OPA verifica que todos existan
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner_alias
    CostCenter  = var.cost_center
  }
}


# ── Módulo 4: Key Vault ────────────────────────────────────────
# Almacén de secretos con RBAC y soft delete habilitados
module "key_vault" {
  source = "../../modules/key-vault"

  name                       = local.keyvault_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  tags                       = local.common_tags
}

# ── Módulo 5: Redis Cache ─────────────────────────────────────
# Caché en memoria para la aplicación — solo SSL, TLS 1.2
module "redis_cache" {
  source = "../../modules/redis-cache"

  name                = "redis-${local.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  capacity            = var.redis_capacity
  family              = var.redis_family
  sku_name            = var.redis_sku
  tags                = local.common_tags

  enable_private_endpoint  = var.redis_enable_private_endpoint
  vnet_name                = var.redis_vnet_name
  pe_subnet_address_prefix = var.redis_pe_subnet_prefix
}

# ── Módulo 6: CosmosDB ────────────────────────────────────────
# Base de datos NoSQL globalmente distribuida (SQL API)
module "cosmosdb" {
  source = "../../modules/cosmosdb"

  name                = "cosmos-${local.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  consistency_level   = "Session"
  tags                = local.common_tags
}
