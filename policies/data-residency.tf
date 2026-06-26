# policies/assignments/data-residency.tf
#
# Canadian data residency, for a Canadian insurer. This is NOT a custom
# policy definition written from scratch -- it uses Azure's built-in
# "Allowed locations" policies directly, supplying our own parameter (the
# Canadian regions). PCI DSS doesn't cover data residency, so this is the
# genuine custom-on-top-of-standard layer the project is built around.
#
# Two built-ins, assigned together for full coverage:
#  - Allowed locations:                    restricts where RESOURCES can be created
#  - Allowed locations for resource groups: restricts where RESOURCE GROUPS can be created
# Without both, someone could still create a resource group in the wrong
# region even if every resource inside it is correctly restricted.

locals {
  allowed_canadian_locations = [
    "canadacentral",
    "canadaeast",
  ]
}

resource "azurerm_subscription_policy_assignment" "allowed_locations_resources" {
  name                 = "canadian-data-residency-resources"
  display_name         = "Canadian data residency - resources"
  description          = "Restricts resource creation to Canadian regions. Custom requirement for this Canadian insurer; not covered by PCI DSS."
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  subscription_id      = data.azurerm_subscription.current.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = local.allowed_canadian_locations
    }
  })
}

resource "azurerm_subscription_policy_assignment" "allowed_locations_resource_groups" {
  name                 = "canadian-data-residency-rgs"
  display_name         = "Canadian data residency - resource groups"
  description          = "Restricts resource GROUP creation to Canadian regions, alongside the resource-level policy, for full coverage."
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988"
  subscription_id      = data.azurerm_subscription.current.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = local.allowed_canadian_locations
    }
  })
}