# modules/compute/variables.tf
#
# This module always creates a NIC. The VM itself is OPTIONAL, controlled by
# create_vm -- the general zone calls this module with create_vm = false to
# get network presence without paying for a VM; the sensitive zone calls it
# with create_vm = true to get the actual claims-processor VM. Same module,
# different behavior, driven entirely by input.

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  description = "Subnet (from the network module's output) this NIC attaches to."
  type        = string
}

variable "nic_name" {
  type = string
}

variable "create_vm" {
  description = "Whether to create a VM attached to this NIC. False for network-only zones (e.g. the general zone)."
  type        = bool
  default     = false
}

variable "vm_name" {
  type    = string
  default = null
}

variable "vm_size" {
  description = "Standard_B2pls_v2 (ARM64) confirmed available on this subscription in canadacentral -- the x86 burstable family (B1s, B2s, etc.) is blocked."
  type        = string
  default     = "Standard_B2pls_v2"
}

variable "admin_username" {
  type    = string
  default = "northwindadmin"
}

variable "ssh_public_key" {
  description = "SSH public key CONTENT (not a file path) -- e.g. tls_private_key.x.public_key_openssh from the caller. Accepting content rather than a path keeps this module portable between local runs and pipeline agents, which have no access to a local filesystem path."
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}