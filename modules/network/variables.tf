# modules/network/variables.tf
#
# This module creates ONE subnet + ONE network security group, attached to
# an EXISTING virtual network (the VNet itself is created once in the
# environment config, not here -- a module that created its own VNet every
# call would produce two separate VNets instead of two subnets inside one).

variable "resource_group_name" {
  description = "Resource group the subnet and NSG are created in."
  type        = string
}

variable "location" {
  description = "Azure region. Must match the VNet's region."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the existing virtual network this subnet belongs to."
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet to create (e.g. snet-sensitive, snet-general)."
  type        = string
}

variable "address_prefix" {
  description = "CIDR block for this subnet, e.g. 10.20.1.0/24."
  type        = string
}

variable "nsg_name" {
  description = "Name of the network security group for this zone."
  type        = string
}

variable "security_rules" {
  description = "List of NSG rules for this zone. The sensitive zone passes a restrictive list; the general zone passes a more permissive one -- same module, different inputs."
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string # "Inbound" or "Outbound"
    access                     = string # "Allow" or "Deny"
    protocol                   = string # "Tcp", "Udp", or "*"
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to the subnet's NSG (subnets themselves don't support tags in azurerm)."
  type        = map(string)
  default     = {}
}