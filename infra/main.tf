
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


resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "SSH-PUBLIC-KEY"
  value        = tls_private_key.key.public_key_openssh
  key_vault_id = module.key_vault.id
  depends_on   = [azurerm_role_assignment.key_vault_secrets_officer]
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "SSH-PRIVATE-KEY"
  value        = tls_private_key.key.private_key_pem
  key_vault_id = module.key_vault.id
  depends_on   = [azurerm_role_assignment.key_vault_secrets_officer]
}

# ------------------------------------------------------------------------------------------------------
# Deploy virtual networks
# ------------------------------------------------------------------------------------------------------

module "vnet" {
  source                     = "./modules/virtual_network"
  name                       = local.vnet_name
  address_space              = var.vm_vnet_address_space
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = var.tags

  subnets = [
    {
      name : "VmSubnet"
      address_prefixes : var.vm_subnet_address_prefix
      private_link_service_network_policies_enabled : false
      default_outbound_access_enabled : true
      delegation : null
      private_endpoint_network_policies : "Disabled"
    },
    {
      name : "AzureBastionSubnet"
      address_prefixes : var.bastion_subnet_address_prefix
      private_link_service_network_policies_enabled : false
      default_outbound_access_enabled : true
      delegation : null
      private_endpoint_network_policies : "Disabled"

    }

  ]

}

# ------------------------------------------------------------------------------------------------------
# Deploy dev test lab
# ------------------------------------------------------------------------------------------------------


module "dev_test_lab" {
  source = "./modules/devtestlab"

  lab_name            = local.dev_test_lab_name
  location            = var.location
  parent_id           = azurerm_resource_group.rg.id
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  lab_storage_type    = var.dtl_storage_type
  announcement        = var.dtl_announcement == null ? local.default_dtl_announcement : var.dtl_announcement

}

module "dev_test_lab_artifiact_source" {
  source               = "./modules/devtestlab_artifact_sources"
  artifact_source_name = var.artifact_source_name
  parent_id            = module.dev_test_lab.id
  location             = var.location
  tags                 = var.tags
  #arm_template_folder_path = var.arm_template_folder_path
  branch_ref     = var.branch_ref
  display_name   = var.display_name
  folder_path    = var.folder_path
  security_token = var.security_token
  source_type    = var.source_type
  status         = var.status
  uri            = var.uri
}


# ------------------------------------------------------------------------------------------------------
# Deploy dev test lab vnet
# ------------------------------------------------------------------------------------------------------

module "dev_test_lab_vnet" {
  source = "./modules/devtestlabs_vnet"

  name      = local.dev_test_lab_vnet_name
  location  = var.location
  parent_id = module.dev_test_lab.id
  tags      = var.tags

  allowed_subnets = [
    {
      allowPublicIp = "Deny"
      labSubnetName = "VmSubnet"
      resourceId    = module.vnet.subnets["VmSubnet"].id
    },
    {
      allowPublicIp = "Allow"
      labSubnetName = "AzureBastionSubnet"
      resourceId    = module.vnet.subnets["AzureBastionSubnet"].id
    }

  ]
  externalProviderResourceId = module.vnet.id
  subnet_overrides = [
    {
      resourceId    = module.vnet.subnets["VmSubnet"].id
      labSubnetName = "VmSubnet"
      sharedPublicIpAddressConfiguration = {
        allowedPorts = [
          {
            backendPort       = 3389
            transportProtocol = "Tcp"
          },
          {
            backendPort       = 22
            transportProtocol = "Tcp"
          }
        ]
      }
      useInVmCreationPermission    = "Allow"
      usePublicIpAddressPermission = "Deny"
    }
  ]

  depends_on = [module.vnet]
}


# ------------------------------------------------------------------------------------------------------
# Deploy network security group
# ------------------------------------------------------------------------------------------------------

module "nsg" {
  source                     = "./modules/network_security_group"
  name                       = local.network_security_group_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = local.tags

  security_rules = [
    {
      name                       = "AllowSshInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AllowRdpInbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AllowInternetOutbound"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Internet"
    }
  ]
}

module "bastion_nsg" {
  source                     = "./modules/network_security_group"
  name                       = "${local.network_security_group_name}-bastion"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = local.tags

  security_rules = [
    {
      name                       = "AllowHttpsInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AllowGatewayManagerInbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AllowAzureLoadBalancerInbound"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AllowSshRdpOutbound"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["22", "3389"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AllowAzureCloudOutbound"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureCloud"
    },
    {
      name                       = "AllowInternetHttpHttpsOutbound"
      priority                   = 120
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["80", "443"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Internet"
    }
  ]
}

resource "azurerm_subnet_network_security_group_association" "vm_subnet_nsg_assoc" {
  subnet_id                 = module.vnet.subnets["VmSubnet"].id
  network_security_group_id = module.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "bastion_subnet_nsg_assoc" {
  subnet_id                 = module.vnet.subnets["AzureBastionSubnet"].id
  network_security_group_id = module.bastion_nsg.id
  depends_on                = [module.vnet]
}

# ------------------------------------------------------------------------------------------------------
# Deploy bastion host
# ------------------------------------------------------------------------------------------------------

module "bastion_host" {
  source                     = "./modules/bastion_host"
  name                       = local.bastion_host_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  subnet_id                  = module.vnet.subnets["AzureBastionSubnet"].id
  log_analytics_workspace_id = module.log_analytics_workspace.id
}


# ------------------------------------------------------------------------------------------------------
# Deploy dev test lab vms
# ------------------------------------------------------------------------------------------------------

module "dev_test_lab_vms" {
  source   = "./modules/devtestlab_vm"
  for_each = local.virtual_machines

  vm_name             = each.key
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags
  lab_id              = module.dev_test_lab.id
  lab_vnet_id         = module.dev_test_lab_vnet.id
  lab_subnet_name     = "VmSubnet"

  gallery_image_reference = local.vm_configs[var.environment][each.value.os_type].image_reference
  vm_size                 = local.vm_configs[var.environment][each.value.os_type].size
  storage_type            = local.vm_configs[var.environment][each.value.os_type].storage_type
  admin_username          = each.value.admin_username
  # artifacts                   = each.value.artifacts
  key_vault_id               = module.key_vault.id
  enable_log_analytics       = var.enable_log_analytics
  log_analytics_workspace_id = module.log_analytics_workspace.workspace_id

  depends_on = [
    azurerm_role_assignment.key_vault_secrets_officer,
    module.dev_test_lab_vnet
  ]
}
