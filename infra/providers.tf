# Configure the Azure Provider
terraform {
  required_version = ">= 1.1.7, < 2.0.0"
  backend "azurerm" {
  }
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "2.0.0-preview3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.13.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }

  }
}


provider "azurerm" {
  skip_provider_registration = "true"
  use_oidc = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

  }
}

provider "azapi" {
}

provider "random" {
}

provider "azurecaf" {
}


# Make client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}
