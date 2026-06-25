# Bootstrap — Terraform state backend (reused)

This project deliberately reuses an existing remote state backend rather than
provisioning a new one. The backend was originally created for an earlier,
related project (`insurance-iac-terraform`) and is intentionally being shared
here rather than duplicated.

**Why reuse rather than create fresh:** in real organizations, a state
backend storage account often outlives the specific project that first
created it — teams consolidate onto shared backend storage rather than
spinning up a new one per project. Reusing it here mirrors that pattern, and
avoids paying for and maintaining a redundant storage account that would do
nothing differently from the one that already exists and works.

## Backend details

These are real, already-applied resources from the earlier project. Every
other Terraform configuration in this repo references them in its
`backend "azurerm"` block:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-northwind-tfstate"
  storage_account_name = "stnorthwindtf676746"
  container_name       = "tfstate"
  key                  = "<config-name>.tfstate"   # unique per configuration
}
```

| Output | Value |
|---|---|
| Resource group | `rg-northwind-tfstate` |
| Storage account | `stnorthwindtf676746` |
| Container | `tfstate` |

Note the naming reflects the earlier project ("northwind"), not this one
("claims-platform") — a cosmetic mismatch, not a functional one. The backend
storage account doesn't care what's stored in it; it's just a place to keep
state files, identified by the `key` each configuration uses.

## Key naming convention for this project

To avoid collisions with the earlier project's state file (which already uses
`infra.tfstate` in this same container), this project's configurations use
distinct keys:

| Configuration | State key |
|---|---|
| `environments/dev` | `claims-platform-dev.tfstate` |
| `policies` | `claims-platform-policies.tfstate` |

## If a fresh backend is ever needed instead

See the original bootstrap Terraform in the `insurance-iac-terraform` repo's
`bootstrap/main.tf` for a from-scratch version (resource group, storage
account with versioning and TLS 1.2 enforced, private container) — this
project doesn't duplicate that code since it isn't needed here.