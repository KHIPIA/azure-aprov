# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Terraform + OPA/Rego lab for Azure (UTEC Posgrado, Module 4, Session 3). Resources are deployed through reusable local Terraform modules, and the plan is validated with Conftest before `apply`. `propuesto.md` is the exercise: build 3 resources using modules and write 2 policy-as-code rules for them. Comments and docs are in Spanish.

The top-level `README.md`, `environments/dev/README.md` and `policy/README.md` describe the **base lab** (log-analytics, storage, container-apps modules and four policies). None of that code is in this repo. Use the READMEs for workflow only, not as a description of the code.

## Tools required

Terraform >= 1.5.0, Azure CLI >= 2.50, conftest >= 0.45.0. The provider is pinned to `azurerm ~> 3.90` in `environments/dev/main.tf` and in every module, so use 3.x attribute names (for example `enable_rbac_authorization`, not the 4.x `rbac_authorization_enabled`).

## Workflow

All Terraform commands run from `environments/dev/`:

```bash
cd environments/dev/
terraform init                      # first time or after adding/changing a module source
terraform validate                  # no Azure auth needed (after init)
terraform plan -out=plan.tfplan
terraform show -json plan.tfplan > plan.json
conftest test plan.json -p ../../policy/              # all policies
conftest test plan.json -p ../../policy/ -o table     # tabular output
conftest test plan.json -p ../../policy/azure_keyvault_secure.rego   # single policy
conftest test plan.json -p ../../policy/ && terraform apply plan.tfplan
terraform destroy -auto-approve
```

`plan.tfplan`, `plan.json`, `.terraform/` and state files are generated artifacts. The repo has no `.gitignore`, so check `git status` before committing.

Auth: `az login && az account set --subscription "<ID>"`.

## Per-student configuration

Edit only `environments/dev/terraform.tfvars`: `resource_group_name` (an existing RG assigned by the instructor; Terraform does not create it) and `owner_alias` (`^[a-z0-9]{2,10}$`, used as a suffix in every resource name).

## Architecture

`environments/dev/main.tf` is the only root module. Current state of the modules:

| Module | Wired in `main.tf`? | Notes |
|---|---|---|
| `modules/key-vault/` | yes | Needs `data.azurerm_client_config.current.tenant_id`. RBAC on, `purge_protection_enabled = false` so the lab can be destroyed. The module validates `soft_delete_retention_days` to 7–90. |
| `modules/aks/` | yes | Minimal demo cluster: Free tier, 1 node, `Standard_B2s` (falls back to `Standard_D2s_v3` if quota fails), kubenet, SystemAssigned identity. `kube_config_raw` output is sensitive and is not re-exported. |
| `modules/acr/` | yes | Container Registry, `Basic` SKU, `admin_enabled = false`. `main.tf` also creates `azurerm_role_assignment.aks_acr_pull` (AcrPull on the ACR for `module.aks.kubelet_object_id`). That assignment needs Owner/User Access Administrator on the RG, or `apply` fails after the registry is created. |
| `modules/cosmosdb/` | commented out | SQL API (`GlobalDocumentDB`), `consistency_level` defaults to `Session`. Its outputs in `outputs.tf` are commented out too. |

Redis Cache was removed (module and policy deleted). However, `environments/dev/variables.tf` still declares the `redis_*` variables and the base lab's `container_*`/replica variables, and `terraform.tfvars` sets some of them. They are unused but harmless. Remove them together if you clean up.

When you enable or disable a module, keep `main.tf`, `outputs.tf` (including the `resumen` map) and `terraform.tfvars` in sync. An output that references a commented-out module breaks `plan`.

Naming, built in the `locals` block:
- `local.suffix` = `"<alias>-<env>"`, e.g. `aks-<alias>-dev`, `cosmos-<alias>-dev`
- `local.keyvault_name` = `kv-<alias[:8]>-<env[:3]>-<md5(rg)[:5]>`: starts with a letter, ≤24 chars, globally unique
- `local.acr_name` = `acr<alias><env[:3]><md5(rg)[:6]>`: alphanumeric only, ≤22 chars, globally unique
- `local.storage_name`: defined but unused (left over from the base lab)

`local.common_tags` (`Environment`, `ManagedBy`, `Owner`, `CostCenter`) is passed as `tags` to every module. New modules should accept a `tags` variable and receive it.

## OPA policies (`policy/`)

Policies use `package main`, `import rego.v1` and `deny contains msg if { ... }`. Any `deny` message makes conftest exit non-zero. Input is `plan.json`. Filter `input.resource_changes[_]` by `type` and by `change.actions` in `{"create","update"}`, then read attributes with `object.get(r.change.after, ...)`. Message prefix convention: `❌ [<policy_name>] '<address>' ...`.

Two policies exist (the two the exercise requires):
- `azure_keyvault_secure.rego`: `enable_rbac_authorization = true`, `soft_delete_retention_days >= 7`
- `azure_acr_secure.rego`: `admin_enabled = false`, `sku` in `{"Basic","Standard"}` (Premium denied)

Since both files are `package main`, rule/variable names must not collide across files. The base-lab policies listed in the READMEs (tags, storage, container resources, location) are not present.

Lab exercise: setting the Key Vault `soft_delete_retention_days` below 7 in `main.tf` is meant to show the policy blocking the plan. But the module's variable validation rejects values below 7 at `plan` time, before conftest runs. To see the Rego deny itself, relax the validation in `modules/key-vault/variables.tf`.
