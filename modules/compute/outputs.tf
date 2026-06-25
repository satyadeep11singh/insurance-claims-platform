# modules/compute/outputs.tf

output "nic_id" {
  value = azurerm_network_interface.this.id
}

output "private_ip_address" {
  value = azurerm_network_interface.this.private_ip_address
}

# Because the VM uses count, it's a list (possibly empty). The general zone
# calls this module with create_vm = false, so vm_id would be an empty list
# -- there's no VM to reference. try() returns null cleanly in that case
# instead of erroring.
output "vm_id" {
  value = try(azurerm_linux_virtual_machine.this[0].id, null)
}

output "vm_name" {
  value = try(azurerm_linux_virtual_machine.this[0].name, null)
}