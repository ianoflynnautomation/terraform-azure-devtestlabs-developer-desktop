
data "azurerm_client_config" "current" {}


# ------------------------------------------------------------------------------------------------------
# Deploy resource Group
# ------------------------------------------------------------------------------------------------------

# resource "random_string" "rg_account_suffix" {
#   length  = 8
#   special = false
#   lower   = true
#   upper   = false
# }

# resource "azurerm_resource_group" "rg" {
#   name     = "rg-${random_string.rg_account_suffix.result}"
#   location = var.location
#   tags     = var.environment
# }

# ------------------------------------------------------------------------------------------------------
# Deploy storage account
# ------------------------------------------------------------------------------------------------------

# resource "random_string" "storage_account_suffix" {
#   length  = 8
#   special = false
#   lower   = true
#   upper   = false
# }

# module "storage_account" {
#   source              = "./modules/storage_account"
#   name                = "sa${random_string.storage_account_suffix.result}"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.rg.name
#   account_kind        = var.storage_account_kind
#   account_tier        = var.storage_account_tier
#   replication_type    = var.storage_account_replication_type
#   container_name      = var.container_name
#   tags = var.tags
# }

# ------------------------------------------------------------------------------------------------------
# Deploy log analytics workspace
# ------------------------------------------------------------------------------------------------------


module "log_analytics_workspace" {
  source              = "../modules/log_analytics_workspace"
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  solution_plan_map   = var.solution_plan_map
  tags                = var.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy key vault
# ------------------------------------------------------------------------------------------------------


module "key_vault" {
  source = "../modules/key_vault"

  name                = "kv-${var.lab_name}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = var.tags

  access_policies = [{
    tenant_id               = data.azurerm_client_config.current.tenant_id
    object_id               = data.azurerm_client_config.current.object_id
    key_permissions         = []
    secret_permissions      = ["Get", "List", "Set", "Delete"]
    certificate_permissions = []
  }]
}

data "azurerm_key_vault_secret" "ado_pat" {
  name         = "ado-pat-token"
  key_vault_id = module.key_vault.id
}

# ------------------------------------------------------------------------------------------------------
# Deploy dev test lab
# ------------------------------------------------------------------------------------------------------


module "dev_test_lab" {
  source = "../modules/devtestlab"

  lab_name                 = var.lab_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  lab_virtual_network_name = "${var.lab_name}-vnet"
  tags                     = var.tags

  lab_storage_type = "Premium"
  allowed_virtual_machine_sizes = [
    "Standard_DS2_v2",
    "Standard_DS3_v2"
  ]

  announcement = {
    enabled  = "Enabled"
    title    = "Welcome to the new Dev Lab!"
    markdown = "Please keep costs in mind. All VMs will be shut down at 7 PM CET."
  }
}

# ------------------------------------------------------------------------------------------------------
# Deploy dev test lab vms
# ------------------------------------------------------------------------------------------------------

module "dev_test_lab_vms" {
  source   = "../modules/devtestlab_vm"
  for_each = { for k, v in local.virtual_machines : k => v if v.is_enabled }

  vm_name                     = each.key
  location                    = var.location
  tags                        = var.tags
  lab_id                      = module.dev_test_lab.id
  lab_vnet_id                 = module.dev_test_lab.vnet_id
  lab_subnet_name             = module.dev_test_lab.subnet_name
  gallery_image_reference     = local.vm_configs[var.environment][each.value.os_type].image_reference
  vm_size                     = local.vm_configs[var.environment][each.value.os_type].size
  storage_type                = local.vm_configs[var.environment][each.value.os_type].storage_type
  admin_username              = each.value.admin_username
  # artifacts                   = each.value.artifacts
  key_vault_id                = module.key_vault.id
  enable_log_analytics        = var.enable_log_analytics
  log_analytics_workspace_id  = module.log_analytics_workspace.workspace_id
  log_analytics_workspace_key = module.log_analytics_workspace.primary_shared_key
}
