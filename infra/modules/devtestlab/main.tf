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

data "azurerm_resource_group" "parent" {
  name = var.resource_group_name
}

resource "azapi_resource" "dtl" {
  type      = "Microsoft.DevTestLab/labs@2018-09-15"
  name      = var.lab_name
  location  = var.location
  parent_id = data.azurerm_resource_group.parent.id
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

resource "azapi_resource" "vnet" {
  type      = "Microsoft.DevTestLab/labs/virtualnetworks@2018-09-15"
  name      = var.lab_virtual_network_name
  location  = var.location
  parent_id = azapi_resource.dtl.id
  tags      = var.tags

  body = {
    properties = {
      subnetOverrides = [
        {
          resourceId                = var.vm_subnet_id
          labSubnetName             = var.vm_subnet_name
          useInVmCreationPermission = "Allow"
        },
        {
          resourceId                = var.bastion_subnet_id
          labSubnetName             = "AzureBastionSubnet"
          useInVmCreationPermission = "Deny"
        }
      ]
    }
  }
}
