data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

locals {
  ama_artifact_name = var.gallery_image_reference.osType == "Windows" ? "ama-installer-windows" : "ama-installer-linux"

  ama_artifact_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.DevTestLab/labs/${split("/", var.lab_id)[8]}/artifactSources/My-Custom-Repo/artifacts/${local.ama_artifact_name}"
  
  ama_artifact = [{
    artifactId = local.ama_artifact_id
    parameters = []
  }]
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
  schema_validation_enabled = false # Required for this older API version

  body = jsonencode({
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
      
      artifacts = concat(var.artifacts, var.enable_log_analytics ? local.ama_artifact : [])
    }
  })

  depends_on = [
    azurerm_key_vault_secret.vm_password_secret
  ]
}