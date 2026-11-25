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

  # Nombre del ACR: solo alfanumérico, 5–50 chars, globalmente único
  # "acr" (3) + alias (max 10) + env (3) + hash (6) = max 22 chars
  acr_name = "acr${var.owner_alias}${substr(var.environment, 0, 3)}${substr(md5(var.resource_group_name), 0, 6)}"

  # Nombre de APIM: empieza con letra, letras/números/guiones, globalmente único
  # "apim-" (5) + alias (max 10) + "-" + env + "-" + hash (5) = ~26 chars
  apim_name = "apim-${local.suffix}-${substr(md5(var.resource_group_name), 0, 5)}"

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


# ── AKS (demos) ───────────────────────────────────────────────
# Cluster mínimo: 1 nodo, tier Free
module "aks" {
  source = "../../modules/aks"

  name                = "aks-${local.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.common_tags
}


# ── ACR (Azure Container Registry) ────────────────────────────
# Registro privado de imágenes para el cluster AKS
module "acr" {
  source = "../../modules/acr"

  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  tags                = local.common_tags
}

# Composición: output de AKS (identidad kubelet) + output de ACR (scope)
# Permite al cluster hacer pull de imágenes del registro.
# Requiere rol Owner o User Access Administrator sobre el RG.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = module.acr.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = module.aks.kubelet_object_id
  skip_service_principal_aad_check = true
}


# ── API Management ────────────────────────────────────────────
# Gateway de APIs, SKU Developer (sin SLA, ~30–60 min en aprovisionar)
module "apim" {
  source = "../../modules/apim"

  name                = local.apim_name
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku_name            = "Developer_1"
  tags                = local.common_tags
}

/*
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
 */
