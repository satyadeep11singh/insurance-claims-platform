# environments/dev/main.tf
#
# This is where the three reusable modules get COMPOSED into the actual
# segmented environment. The network module is called twice -- once for the
# sensitive zone, once for the general zone -- with different inputs each
# time. That's the literal mechanism behind "the network module is reusable":
# it's the same module block, just parameterized differently.

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-claims-platform"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.20.0.0/16"]
  tags                = var.tags
}

resource "random_id" "suffix" {
  byte_length = 3
}

# Generated, not supplied: nobody is meant to SSH into this VM -- it exists
# to be governed by policy, not logged into. Generating the key here removes
# any dependency on a local file path (which doesn't exist in a pipeline
# agent anyway, and was a source of Windows-path issues locally).
resource "tls_private_key" "claims_processor" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- Sensitive zone ---
# Restrictive NSG: only allows inbound traffic from the general zone's
# address range, on no ports by default (deny-by-default is the point --
# add an explicit allow rule here only if a real cross-zone flow is needed).
module "network_sensitive" {
  source = "../../modules/network"

  resource_group_name  = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  virtual_network_name = azurerm_virtual_network.main.name
  subnet_name           = "snet-sensitive"
  address_prefix        = "10.20.1.0/24"
  nsg_name              = "nsg-sensitive"
  tags                  = var.tags

  security_rules = [
    {
      name                       = "DenyAllInboundFromGeneral"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.20.2.0/24"
      destination_address_prefix = "*"
    }
  ]
}

module "compute_sensitive" {
  source = "../../modules/compute"

  resource_group_name = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  subnet_id            = module.network_sensitive.subnet_id
  nic_name             = "nic-claims-processor"
  tags                 = var.tags

  create_vm            = true
  vm_name              = "vm-claims-processor"
  admin_username       = var.admin_username
  ssh_public_key       = tls_private_key.claims_processor.public_key_openssh
}

# --- General zone ---
# Baseline NSG, more permissive than the sensitive zone. No VM: the
# segmentation story is carried by the subnet + NSG, not a second VM.
module "network_general" {
  source = "../../modules/network"

  resource_group_name  = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  virtual_network_name = azurerm_virtual_network.main.name
  subnet_name           = "snet-general"
  address_prefix        = "10.20.2.0/24"
  nsg_name              = "nsg-general"
  tags                  = var.tags

  security_rules = [
    {
      name                       = "AllowVnetInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    }
  ]
}

# --- Storage ---
module "storage_claims" {
  source = "../../modules/storage"

  resource_group_name  = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  storage_account_name = "stclaimsdocs${random_id.suffix.hex}"
  tags                  = var.tags
}