##############################################################
# modules/redis-cache/main.tf
#
# Módulo reutilizable: Azure Redis Cache
# Capa de caché en memoria para la aplicación.
# Configurado de forma segura: solo SSL, TLS 1.2 mínimo.
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

resource "azurerm_redis_cache" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name

  # Seguridad: requerido por azure_redis_secure.rego
  enable_non_ssl_port = false       # deshabilita puerto 6379 (sin cifrado)
  minimum_tls_version = "1.2"      # fuerza TLS 1.2 en puerto 6380

  redis_configuration {}

  tags = var.tags
}

# ── Private Endpoint (optional) ───────────────────────────────

data "azurerm_virtual_network" "existing" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "pe" {
  count                = var.enable_private_endpoint ? 1 : 0
  name                 = "${var.name}-pe-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.existing[0].name
  address_prefixes     = [var.pe_subnet_address_prefix]

  private_endpoint_network_policies_enabled = false
}

resource "azurerm_private_dns_zone" "redis" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "${var.name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.redis[0].name
  virtual_network_id    = data.azurerm_virtual_network.existing[0].id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "redis" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = azurerm_subnet.pe[0].id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.name}-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis[0].id]
  }

  tags = var.tags
}
