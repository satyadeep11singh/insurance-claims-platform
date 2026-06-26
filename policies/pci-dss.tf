resource "azurerm_subscription_policy_assignment" "pci_dss" {
  name                 = "pci-dss-v4-0-1-baseline"
  display_name         = "PCI DSS v4.0.1 - Northwind Mutual claims platform"
  description          = "Audits the claims platform against the PCI DSS v4.0.1 regulatory compliance initiative. Relevant because the platform represents infrastructure for an insurer that processes payments (premiums, payouts)."
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/a06d5deb-24aa-4991-9d58-fa7563154e31"
  subscription_id      = data.azurerm_subscription.current.id

  # Required even in audit-only mode: PCI DSS v4.0.1 includes some member
  # policies with a DeployIfNotExists effect (e.g. auto-deploying missing
  # diagnostic settings). Azure requires a managed identity to exist on the
  # assignment for ANY initiative containing such policies, regardless of
  # whether enforcement is active. `location` is required whenever `identity`
  # is set.
  #
  # Deliberately NOT chased further: actually wiring up auto-remediation
  # would require enumerating each DeployIfNotExists sub-policy's specific
  # role requirement and granting it individually (a known gap -- the
  # provider doesn't do this automatically). Out of scope here since this
  # assignment runs audit-only (enforce = false); the identity below
  # satisfies Azure's creation-time requirement without claiming to support
  # remediation this project doesn't actually use.
  identity {
    type = "SystemAssigned"
  }
  location = "canadacentral"

  # Audit, not Deny: the PCI DSS initiative contains controls that legitimately
  # should not hard-block deployment (e.g. controls about organizational
  # process, not infrastructure config). Audit-only is the standard,
  # recommended pattern for broad regulatory-compliance initiatives -- you
  # assess posture against them, then remediate or exempt individual findings,
  # rather than letting the whole initiative block resource creation.
  #
  # Terraform's argument here is `enforce` (boolean) -- NOT `enforcement_mode`
  # (that's the underlying ARM REST API's property name, a different surface
  # from the Terraform provider's own argument).
  enforce = false
}