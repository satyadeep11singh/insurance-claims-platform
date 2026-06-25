# modules/network/outputs.tf

output "subnet_id" {
  description = "ID of the created subnet -- used by the compute module to attach a NIC."
  value       = azurerm_subnet.this.id
}

output "subnet_name" {
  value = azurerm_subnet.this.name
}

output "nsg_id" {
  value = azurerm_network_security_group.this.id
}

output "nsg_name" {
  value = azurerm_network_security_group.this.name
}