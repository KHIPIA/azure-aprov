# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Terraform + OPA/Rego lab for Azure (UTEC Posgrado, Module 4, Session 3). It deploys resources via reusable Terraform modules, then validates the plan with Conftest before applying. The `propuesto.md` exercise asked for three new modules and two new OPA policies — those are the three modules in `modules/` and the two policies for Key Vault and Redis.

## Tools required

- Terraform >= 1.5.0
- Azure CLI >= 2.50
- conftest >= 0.45.0 (OPA policy runner)

```bash
# Verify installations
terraform version && az version && conftest --version
```

## Workflow

All Terraform commands run from `environments/dev/`:

```bash
cd environments/dev/

# Syntax check (no Azure auth required)
terraform validate

# Init (first time or after module changes)
terraform init

# Plan and export as JSON (required for policy validation)
terraform plan -out=plan.tfplan
terraform show -json plan.tfplan > plan.json

# Validate policies before applying
conftest test plan.json -p ../../policy/
conftest test plan.json -p ../../policy/ -o table   # table format, easier to read

# Apply only if policies pass
conftest test plan.json -p ../../policy/ && terraform apply plan.tfplan

# Tear down
terraform destroy -auto-approve
```

Run a single policy:
```bash
conftest test plan.json -p ../../policy/azure_redis_secure.rego
```

`plan.tfplan` and `plan.json` are generated artifacts — do not commit them.

## Per-student configuration

The only file each user should edit is `environments/dev/terraform.tfvars`. Set:
- `resource_group_name` — assigned by the instructor (e.g. `rg-alumno-01`)
- `owner_alias` — unique lowercase alias, 2–10 alphanumeric chars (regex `^[a-z0-9]{2,10}$`), used as a suffix on all resource names to avoid collisions

## Architecture

`environments/dev/main.tf` wires three modules (the exercise additions — the base lab's `log_analytics`, `storage`, and `container_apps` modules referenced in the file's header comment are not present in this repo):

```
module "key_vault"      →  modules/key-vault/
    inputs: data.azurerm_client_config.current.tenant_id
    outputs: vault_name, vault_uri

module "redis_cache"    →  modules/redis-cache/
    outputs: redis_hostname, redis_ssl_port, redis_primary_connection_string (sensitive)
    optional Private Endpoint (redis_enable_private_endpoint): looks up an EXISTING VNet
    (redis_vnet_name, in the same resource group), creates a subnet in it plus a private DNS zone.
    Requires Standard/Premium SKU; with it enabled, `plan` fails if the VNet doesn't exist.

module "cosmosdb"       →  modules/cosmosdb/
    outputs: cosmosdb_name, cosmosdb_endpoint, cosmosdb_primary_key (sensitive), cosmosdb_connection_strings (sensitive)
```

`key_vault` requires `data "azurerm_client_config" "current"` for the tenant ID. `cosmosdb` uses SQL API (`kind = "GlobalDocumentDB"`) with `consistency_level = "Session"` by default.

The `locals` block builds naming patterns:
- **Storage Account** (`local.storage_name`, no storage module in this repo yet): `"st" + alias(10) + env(3) + md5hash(6)` — alphanumeric only, max 24 chars
- **Key Vault**: `"kv-" + alias(8) + "-" + env(3) + "-" + md5hash(5)` — must start with a letter, max 24 chars, globally unique in Azure

All four required tags (`Environment`, `ManagedBy`, `Owner`, `CostCenter`) should appear on every taggable resource (enforced by `azure_required_tags.rego` once present). These are set in `local.common_tags` in `main.tf`.

### Lab exercise: policy violation

`environments/dev/main.tf:62` currently sets `soft_delete_retention_days = 7` (compliant). The lab's exercise is to observe `azure_keyvault_secure.rego` block a value `< 7` and then fix it. Note the module's `variables.tf` also validates 7–90, so values below 7 fail at `terraform validate`/`plan` before reaching conftest.

## OPA policies (`policy/`)

All policies use `package main` and the `deny` rule pattern — a non-empty `deny` set causes `conftest` to exit non-zero. Policies receive `plan.json` as `input`; resources are read from `input.resource_changes[_]`.

Only `azure_keyvault_secure.rego` and `azure_redis_secure.rego` exist in `policy/` right now; the other four rows below describe the base lab's policies and are **not present** in this repo (add them before relying on them, e.g. the tags policy).

| Policy file | What it enforces |
|---|---|
| `azure_required_tags.rego` | Tags `Environment`, `ManagedBy`, `Owner`, `CostCenter` on all resources (empty tags also fail) |
| `azure_storage_secure.rego` | `allow_nested_items_to_be_public = false`, TLS 1.2+, HTTPS only |
| `azure_container_resources.rego` | CPU ≤ 1.0 vCPU, RAM ≤ 2Gi, replicas ≤ 5 |
| `azure_location.rego` | Only `eastus`, `eastus2`, `westus2` |
| `azure_keyvault_secure.rego` | `enable_rbac_authorization = true`, `soft_delete_retention_days >= 7` |
| `azure_redis_secure.rego` | `enable_non_ssl_port = false`, `minimum_tls_version = "1.2"` |

## Azure authentication

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
az account show --query '{Nombre:name, ID:id}' --output table
```
