# modules/compute/main.tf

# The NIC is always created -- this is what gives a zone network presence,
# VM or not. Deliberately no public_ip_address_id anywhere in this module:
# nothing this project creates is directly internet-facing.
resource "azurerm_network_interface" "this" {
  name                = var.nic_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# count = create_vm ? 1 : 0 is Terraform's way of making a whole resource
# conditional. When create_vm is false, this block evaluates to a list of
# zero VMs -- nothing is created. When true, exactly one VM is created.
resource "azurerm_linux_virtual_machine" "this" {
  count = var.create_vm ? 1 : 0

  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # ARM64-specific SKU -- confirmed available in canadacentral. The non-arm64
  # sku (22_04-lts-gen2) will NOT boot on an ARM64 VM size like B2pls_v2.
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-arm64"
    version   = "latest"
  }
}