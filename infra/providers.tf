# Configure the Azure Provider
terraform {
  required_version = ">= 1.1.7, < 2.0.0"
   backend "azurerm" {
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.114.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.14.0"
    }
    
  }
}


provider "azurerm" {
  features {}
}

provider "azapi" {
}

# Make client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}
