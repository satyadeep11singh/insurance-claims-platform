# modules/storage/main.tf
#
# Hardened storage account representing where claims documents would live.
# Every security-relevant setting here is explicit, not relied-upon-as-default
# -- the same "state is PII, treat sensitive data accordingly" principle
# applied to the claims-documents store itself, since this is the resource
# the PCI DSS storage-encryption and secure-transfer policies (Stage 6)
# specifically check.

resource "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version             = "TLS1_2"
  https_traffic_only_enabled  = true

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "this" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}