data "azurerm_client_config" "current" {}

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

resource "azapi_resource" "dtl" {
  type      = "Microsoft.DevTestLab/labs@2018-09-15"
  name      = var.lab_name
  location  = var.location
  parent_id = var.parent_id
  tags      = var.tags

  body = {
    properties = {
      labStorageType   = var.lab_storage_type
      premiumDataDisks = var.premium_data_disks
      announcement     = var.announcement
      support          = var.support
    }
  }
}
