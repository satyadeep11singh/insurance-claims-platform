# Northwind Mutual — Compliance-Governed Claims Platform

Modular Terraform + Azure DevOps + Azure Policy, provisioning a
network-segmented claims-processing environment for a fictional insurer,
governed by Azure's real PCI DSS regulatory compliance initiative plus a
custom Canadian data-residency policy.

> **Disclaimer:** "Northwind Mutual" is a fictional company. All
> infrastructure, naming, and configuration in this project are for personal
> learning purposes only and do not represent or use any real systems, data,
> or processes from any actual insurance company or employer.

---

## What this project demonstrates

Anyone can write Terraform to create a virtual machine. The harder, more
valuable skill is *governing* infrastructure so it can't be created in a
non-compliant way in the first place, and *structuring* that infrastructure
the way a platform team actually would: as reusable building blocks, not a
single flat script.

This project provisions a small, network-segmented claims-processing
environment using reusable Terraform modules, deployed through Azure DevOps
pipelines with a human approval gate between plan and apply, and governed by
Azure's real built-in **PCI DSS regulatory compliance initiative** — the same
one regulated companies actually assign — extended with a custom **Canadian
data residency** policy specific to a Canadian insurer's regulatory context.

### Why PCI DSS and data residency specifically

Insurers process payments (premiums, payouts), so PCI DSS genuinely applies.
Canadian data residency reflects a real constraint for a Canadian insurer:
customer and claims data is expected to stay within Canadian borders. Using
Azure's *built-in, Microsoft-maintained* PCI DSS initiative — rather than
hand-writing equivalent rules — mirrors how a real compliance team would
work: adopt the recognized industry standard, then layer organization-specific
rules on top only where the standard doesn't already cover it.

---

## Architecture

### Governance and network structure

![Governance and network structure](./docs/governance-structure-v2.png)

The compliance layer (PCI DSS plus Canadian data residency) is enforced at
the subscription level — it isn't a resource you can point at, it's a standing
rule that evaluates everything underneath it. Inside the resource group, the
virtual network is split into two segments:

- **Sensitive zone** (`snet-sensitive`) — holds the claims-processor VM and is
  governed by its own NSG. This is the project's equivalent of a PCI
  "cardholder data environment": the place sensitive data and its processing
  live, deliberately isolated.
- **General zone** (`snet-general`) — a general-purpose tier with its own NSG
  and baseline rules, but no VM. Network-only by design: the segmentation
  story is carried by the subnets and NSG rules, not by running a second VM,
  which keeps the realistic two-tier pattern at roughly the cost of one.

NSGs control exactly what traffic is allowed to cross between the two zones.

### Pipeline flow

![Pipeline flow](./docs/pipeline-flow-v2.png)

Infrastructure is defined as three reusable Terraform modules — `network`,
`compute`, and `storage` — composed by a root environment configuration
rather than described directly. The Build Pipeline only ever validates and
plans: `terraform init` against the remote state backend, `terraform
validate`, then `terraform plan -out=tfplan`, publishing that exact plan as a
pipeline artifact. The Release Pipeline downloads that artifact and applies
it — first to a `staging` Azure DevOps Environment automatically, then it
pauses at a manual approval gate before applying the *same* artifact to
`production`. The plan is never regenerated between staging and production:
what was reviewed is exactly what gets applied.

---

## Resource list

| Resource | Name | Module | Notes |
|---|---|---|---|
| Resource group | `rg-claims-platform-dev` | — | Single resource group for the dev environment |
| **Sensitive zone** | | | |
| Virtual network | `vnet-claims-platform` | `network` | One VNet, two subnets |
| Subnet | `snet-sensitive` (10.20.1.0/24) | `network` | Claims data and processing |
| Network security group | `nsg-sensitive` | `network` | Denies inbound except explicitly allowed traffic from the general zone |
| Network interface | `nic-claims-processor` | `compute` | No public IP |
| Virtual machine | `vm-claims-processor` (`Standard_B2pls_v2`, ARM64) | `compute` | The one real VM in the project; nothing runs on it, it exists to be governed |
| Storage account | `stclaimsdocs<unique>` | `storage` | Claims documents; HTTPS-only, encrypted, private |
| Storage container | `claims-documents` | `storage` | |
| **General zone** | | | |
| Subnet | `snet-general` (10.20.2.0/24) | `network` | App/general-purpose workloads |
| Network security group | `nsg-general` | `network` | Baseline rules, more permissive than the sensitive zone |
| — | (no VM) | — | Network-only, deliberately, to keep cost low |
| **Governance** | | | |
| Policy initiative assignment | PCI DSS (built-in) | `policies` | Subscription scope |
| Policy assignment | Canadian data residency (custom) | `policies` | Subscription scope, layered on top of PCI DSS |

---

## Repository structure

```
/modules
  /network        # reusable: vnet, subnet, nsg, rules
  /compute        # reusable: nic, optional vm
  /storage        # reusable: storage account + container, hardened
/environments
  /dev            # root config composing the modules for the dev environment
/policies
  /initiatives    # PCI DSS initiative assignment + custom data-residency
  /assignments
/bootstrap        # one-time remote state backend setup
/pipelines        # Build and Release pipeline YAML
```

Why modules: the network module is instantiated twice — once for the
sensitive zone, once for the general zone — with different inputs each time.
That reuse is the actual point: the same reviewed, tested template produces
both segments, rather than two independently hand-written, easily-diverging
copies.

---

## State management

Terraform state is stored remotely in Azure Blob Storage (set up once via
`/bootstrap`), never locally. State files can contain secrets and access
tokens in plaintext — in a regulated insurance context, state is treated with
the same rigor as customer PII: encrypted, access-controlled, and locked
against concurrent writes.

## Authentication

Pipelines authenticate to Azure via OIDC / Workload Identity Federation — no
stored secret in either pipeline. A long-lived service-principal secret is
exactly the kind of credential a security audit at an insurance company would
flag.

---

## Project status

This is a from-scratch rebuild of an earlier draft (the draft proved the core
pattern — Terraform, remote state, OIDC, a basic policy — end to end; this
version restructures that into modules and replaces the basic policy layer
with the real PCI DSS initiative and network segmentation described above).
Build is in progress; sections below will be filled in commit by commit.

## CI/CD pipelines

*(filled in as Stages 5–7 are built)*

## The compliance initiative in practice

*(filled in in Stage 6 — screenshots of the PCI DSS compliance score and the
data-residency policy denying a non-compliant deployment)*

## Cost-conscious design

*(filled in at project completion)*

## What a production deployment would add

*(deliberately deferred — filled in at project completion: private endpoints
on storage, management-group-scope policy assignment, hub-spoke networking
with Azure Firewall, DeployIfNotExists remediation policies, Key Vault for
secrets, true multi-environment infrastructure rather than an approval-workflow
distinction)*