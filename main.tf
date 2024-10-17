terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "TFstateVPN"
      storage_account_name = "tfstatevpn1"
      container_name       = "tfstate"
      key = "terraform.tfstate"
      use_azuread_auth = true
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "tfVPNconfig"
  location = "East US"
}