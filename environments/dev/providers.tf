# environments/dev/providers.tf
#
# Reuses the existing state backend from the earlier project (see
# /bootstrap/README.md for why), with a distinct key so this project's state
# never collides with the earlier project's infra.tfstate in the same
# container.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.95"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-northwind-tfstate"
    storage_account_name = "stnorthwindtf676746"
    container_name       = "tfstate"
    key                  = "claims-platform-dev.tfstate"
  }
}

provider "azurerm" {
  features {}
}