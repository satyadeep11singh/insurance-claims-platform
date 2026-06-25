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

variable "tags" {
  type = map(string)
  default = {
    Environment        = "dev"
    CostCenter          = "northwind-claims"
    Owner               = "satyadeep"
    DataClassification  = "sensitive-claims"
  }
}