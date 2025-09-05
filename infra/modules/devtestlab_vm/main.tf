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
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

resource "random_password" "vm_password" {
  length      = 24
  special     = true
  min_numeric = 4
  min_upper   = 4
  min_special = 2
}

resource "azurerm_key_vault_secret" "vm_password_secret" {
  name         = "vm-password-${var.vm_name}"
  value        = random_password.vm_password.result
  key_vault_id = var.key_vault_id
  tags = {
    vm_name = var.vm_name
  }
}


resource "azapi_resource" "vm" {
  type                      = "Microsoft.DevTestLab/labs/virtualmachines@2018-09-15"
  name                      = var.vm_name
  location                  = var.location
  parent_id                 = var.lab_id
  tags                      = var.tags
  schema_validation_enabled = false

  body = {
    properties = {
      galleryImageReference   = var.gallery_image_reference
      allowClaim              = false
      disallowPublicIpAddress = true
      labSubnetName           = var.lab_subnet_name
      labVirtualNetworkId     = var.lab_vnet_id
      password                = random_password.vm_password.result
      size                    = var.vm_size
      storageType             = var.storage_type
      userName                = var.admin_username

      # artifacts = concat(var.artifacts, var.enable_log_analytics ? local.ama_artifact : [])
    }
  }

  depends_on = [
    azurerm_key_vault_secret.vm_password_secret
  ]
}
