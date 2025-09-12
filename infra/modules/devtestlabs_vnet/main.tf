terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "2.6.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.42.0"
    }
  }
}

resource "azapi_resource" "vnet" {
  type      = "Microsoft.DevTestLab/labs/virtualnetworks@2018-09-15"
  name      = var.name
  location  = var.location
  parent_id = var.parent_id
  tags      = var.tags

  body = {
    properties = {
      allowedSubnets             = var.allowed_subnets
      externalProviderResourceId = var.externalProviderResourceId
      subnetOverrides            = var.subnet_overrides
    }
  }
}
