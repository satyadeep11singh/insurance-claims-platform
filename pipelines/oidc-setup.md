# OIDC authentication setup

This project authenticates Azure DevOps pipelines to Azure using OIDC /
Workload Identity Federation via a **managed identity** — no stored secret
anywhere.

## What's set up

- **Managed identity:** `id-claims-platform-pipeline`, in its own resource
  group `rg-claims-platform-identity` (kept separate from
  `rg-claims-platform-dev` deliberately — this identity is pipeline tooling,
  not part of the claims environment itself, so it isn't affected when the
  dev environment is torn down between sessions)
- **Azure DevOps service connection:** `claims-platform-oidc-connection`,
  using "Managed identity (automatic)" — Azure DevOps created the federated
  credential on the managed identity itself, automatically
- **Roles granted to the managed identity:**
  - `Contributor` at subscription scope (assigned automatically by the
    service connection wizard)
  - `Resource Policy Contributor` at subscription scope (added manually —
    needed for the PCI DSS and data-residency policy assignments in
    `policies/`)
  - `Storage Blob Data Contributor`, scoped narrowly to just the reused
    state backend storage account (`stnorthwindtf676746`) — not the whole
    subscription

## Why managed identity instead of an app registration this time

An earlier related project (`insurance-iac-terraform`) used an app
registration created via the Azure CLI, and Azure DevOps's "automatic"
Workload Identity Federation mode failed against it with an internal
"strong box" error. Per Microsoft's own documentation, this is a known,
documented limitation: automatic conversion/creation can fail when Azure
DevOps needs to write a federated credential onto an identity it didn't
create itself. The fix that worked there was manual completion — copying
the generated Issuer and Subject identifier and creating the federated
credential directly via `az ad app federated-credential create`.

For this project, a managed identity was created fresh in the Azure Portal
specifically so Azure DevOps's automatic flow could create both the
identity's federated credential and the service connection together, with
no pre-existing object to conflict with. This succeeded automatically on
the first attempt — confirmed by checking
`az identity federated-credential list` directly against the managed
identity, which showed a real federated credential whose issuer and subject
exactly matched what Azure DevOps displayed.

This is a useful, real comparison: the original failure was specific to
modifying a pre-existing identity Azure DevOps didn't create, not a general
problem with workload identity federation.

## Verifying it yourself

```bash
az identity show --name id-claims-platform-pipeline \
  --resource-group rg-claims-platform-identity \
  --query "principalId" -o tsv

az identity federated-credential list \
  --identity-name id-claims-platform-pipeline \
  --resource-group rg-claims-platform-identity

az role assignment list --assignee <principalId> -o table
```