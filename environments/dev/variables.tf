# environments/dev/variables.tf

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "resource_group_name" {
  type    = string
  default = "rg-claims-platform-dev"
}

variable "admin_username" {
  type    = string
  default = "northwindadmin"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key. No default -- supply in terraform.tfvars (gitignored)."
  type        = string
}

variable "tags" {
  type = map(string)
  default = {
    Environment        = "dev"
    CostCenter          = "northwind-claims"
    Owner               = "satyadeep"
    DataClassification  = "sensitive-claims"
  }
}