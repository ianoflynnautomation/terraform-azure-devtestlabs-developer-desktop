
data "azurerm_client_config" "current" {}

# ------------------------------------------------------------------------------------------------------
# Deploy resource Group
# ------------------------------------------------------------------------------------------------------


resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy log analytics workspace
# ------------------------------------------------------------------------------------------------------


module "log_analytics_workspace" {
  source              = "./modules/log_analytics_workspace"
  name                = local.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  solution_plan_map   = var.solution_plan_map
  tags                = var.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy key vault
# ------------------------------------------------------------------------------------------------------


module "key_vault" {
  source                          = "./modules/key_vault"
  name                            = local.key_vault_name
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  tags                            = var.tags
  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  bypass                          = var.key_vault_bypass
  default_action                  = var.key_vault_default_action
  log_analytics_workspace_id      = module.log_analytics_workspace.workspace_id

}

resource "azurerm_role_assignment" "key_vault_secrets_officer" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  depends_on           = [module.key_vault]
}


# resource "tls_private_key" "key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "azurerm_key_vault_secret" "ssh_public_key" {
#   name         = "ssh-public-key-openssh"
#   value        = tls_private_key.key.public_key_openssh
#   key_vault_id = module.key_vault.id
#   depends_on   = [azurerm_role_assignment.key_vault_admin]
# }

# ------------------------------------------------------------------------------------------------------
# Deploy dev test lab
# ------------------------------------------------------------------------------------------------------


module "dev_test_lab" {
  source = "./modules/devtestlab"

  lab_name                 = local.dev_test_lab_name
  lab_virtual_network_name = local.dev_test_lab_vnet_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  tags                     = var.tags

  lab_storage_type = var.dtl_storage_type
  announcement     = var.dtl_announcement == null ? local.default_dtl_announcement : var.dtl_announcement
  subnet_overrides = var.dtl_subnet_overrides == null ? local.default_dtl_subnet_overrides : var.dtl_subnet_overrides

  depends_on = [azurerm_resource_group.rg]
}


# ------------------------------------------------------------------------------------------------------
# Deploy dev test lab vms
# ------------------------------------------------------------------------------------------------------

module "dev_test_lab_vms" {
  source   = "./modules/devtestlab_vm"
  for_each = local.virtual_machines

  vm_name                 = each.key
  resource_group_name     = azurerm_resource_group.rg.name
  location                = var.location
  tags                    = var.tags
  lab_id                  = module.dev_test_lab.id
  lab_vnet_id             = module.dev_test_lab.vnet_id
  lab_subnet_name         = module.dev_test_lab.subnet_name
  gallery_image_reference = local.vm_configs[var.environment][each.value.os_type].image_reference
  vm_size                 = local.vm_configs[var.environment][each.value.os_type].size
  storage_type            = local.vm_configs[var.environment][each.value.os_type].storage_type
  admin_username          = each.value.admin_username
  # artifacts                   = each.value.artifacts
  key_vault_id               = module.key_vault.id
  enable_log_analytics       = var.enable_log_analytics
  log_analytics_workspace_id = module.log_analytics_workspace.workspace_id

  depends_on = [
    azurerm_role_assignment.key_vault_secrets_officer
  ]
}
