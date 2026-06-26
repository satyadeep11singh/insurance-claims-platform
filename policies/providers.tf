# policies/providers.tf
#
# Policy work gets its OWN Terraform state, separate from environments/dev.
# Policies are subscription-scoped and conceptually permanent -- they should
# keep evaluating compliance even between sessions when rg-claims-platform-dev
# doesn't exist. Mixing this into the same state as the dev environment would
# mean every environment teardown/rebuild touches the same state file as the
# permanent governance layer.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.95"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-northwind-tfstate"
    storage_account_name = "stnorthwindtf676746"
    container_name       = "tfstate"
    key                  = "claims-platform-policies.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}