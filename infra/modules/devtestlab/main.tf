terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

resource "azapi_resource" "dtl" {
  type      = "Microsoft.DevTestLab/labs@2018-09-15"
  name      = var.lab_name
  location  = var.location
  parent_id = data.azurerm_resource_group.parent.id
  tags      = var.tags

  body = jsonencode({
    properties = {
      labStorageType            = var.lab_storage_type
      premiumDataDisks          = var.premium_data_disks
      announcement              = var.announcement
      support                   = var.support
    }
  })
}


resource "azapi_resource" "vnet" {
  type      = "Microsoft.DevTestLab/labs/virtualnetworks@2018-09-15"
  name      = var.lab_virtual_network_name
  location  = var.location
  parent_id = azapi_resource.dtl.id
  tags      = var.tags

  body = jsonencode({
    properties = {
      subnetOverrides = var.subnet_overrides
    }
  })
}