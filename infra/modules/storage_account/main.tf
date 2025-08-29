terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                = var.name
  resource_group_name = var.resource_group_name

  location                 = var.location
  account_kind             = var.account_kind
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  is_hns_enabled           = var.is_hns_enabled
  tags                     = var.tags

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_container" "container" {
  name               = var.container_name
  storage_account_id = azurerm_storage_account.storage_account.id
}
