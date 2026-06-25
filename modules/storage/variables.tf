# modules/storage/variables.tf

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  description = "Must be globally unique across all of Azure, lowercase, no hyphens."
  type        = string
}

variable "container_name" {
  type    = string
  default = "claims-documents"
}

variable "tags" {
  type    = map(string)
  default = {}
}