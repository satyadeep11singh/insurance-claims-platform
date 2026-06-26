# Compliance demonstration notes

## Status

- **PCI DSS v4.0.1 initiative**: assigned (`enforce = false`, audit-only).
  Compliance score takes 24-48 hours to populate after assignment (per
  Microsoft's own guidance) -- check back and capture
  `pci-compliance-score.png` once it shows real data, not "Not started."
- **Canadian data residency (resources + resource groups)**: assigned and
  enforcing (`enforce = true`). Verified working immediately -- Deny effects
  evaluate at creation time, not on a periodic scan, so no waiting period
  applies.

## Deny demonstration -- both halves independently verified

Two separate test attempts, both correctly blocked:

1. **Resource-group-level deny**: `az group create --location eastus`
   rejected by the `canadian-data-residency-rgs` assignment, citing the
   built-in "Allowed locations for resource groups" policy. Confirmed the
   resource group was never actually created
   (`az group show` → `ResourceGroupNotFound`).

2. **Resource-level deny**: `az storage account create --location eastus`
   (inside an existing, correctly-located resource group) rejected by the
   *separate* `canadian-data-residency-resources` assignment, citing the
   built-in "Allowed locations" policy -- confirming the two built-in
   policies are independently doing their distinct jobs (one governs where
   resource groups can exist, the other governs where resources inside them
   can exist).

Both denials were corroborated independently in the Azure Portal's
Activity Log (Monitor → Activity log), showing the identical
`RequestDisallowedByPolicy` error with a timestamp and the initiating
identity -- confirming this is a real, audited control-plane decision, not
just a CLI-side message.

Screenshots: `data-residency-deny-cli.png`,
`data-residency-deny-resource-level.png`,
`data-residency-deny-activity-log.png`,
`portal-policy-assignments-overview.png`