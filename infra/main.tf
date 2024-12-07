
locals {
  tags                          = { azd-env-name : var.environment_name }
  windows_client_vm_count_total = [for i in range(var.windows_client_vm_count) : tostring(i)]
  lab_name                      = "lab-${var.environment_name}"
}

resource "random_password" "password" {
  count       = 1
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 1
}

resource "azurecaf_name" "rg_name" {
  name          = var.environment_name
  resource_type = "azurerm_resource_group"
  random_length = 0
  clean_input   = true
}

# ------------------------------------------------------------------------------------------------------
# Deploy resource Group
# ------------------------------------------------------------------------------------------------------

resource "azurerm_resource_group" "rg-devtestlabs" {
  name     = azurecaf_name.rg_name.result
  location = var.location
  tags     = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy Lab Module
# ------------------------------------------------------------------------------------------------------

module "lab" {
  source                  = "./modules/devtestlab"
  location                = azurerm_resource_group.rg-devtestlabs.location
  lab_name                = local.lab_name
  windows_client_vm_count = local.windows_client_vm_count_total
  tags                    = local.tags
}
