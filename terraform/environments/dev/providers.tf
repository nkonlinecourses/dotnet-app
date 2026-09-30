terraform {
  required_version = ">= 1.6.0"

  # Backend settings are supplied by the Azure DevOps pipeline.
  # The state storage account/container are bootstrapped separately.
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
