data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.13.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.1.0"
    }
  }
}

locals {
  lab_virtual_network_name          = "Dtl${var.lab_name}"
  ado_agent_path                    = "/agent"
  linux_installer_docker_package    = "linux-installer-docker"
  linux_app_server_vm_name          = "linuxvm01"
  linux_app_server_vm_username      = "tester"
  apt_docker_compose_plugin_options = ""
  apt_docker_compose_plugin_update  = "true"
  apt_docker_compose_plugin_package = "docker-compose"
  allow_claim                       = false
  vm_admin_password                 = random_password.password[0].result
  vm_password                       = random_password.password[1].result
  replace_agent                     = "true"
  work_directory                    = ""
  driver_letter                     = "C"
  run_as_auto_logon                 = "false"
  agent_name_suffix                 = ""
  windows_logon_account             = ""
  ado_agent_name                    = "agent"
  az_ignore_checksums               = "false"
  az_allow_empty_checksums          = "true"
  az_packages                       = "azure-cli"
  ps_ignore_checksums               = "false"
  ps_allow_empty_checksums          = "true"
  ps_packages                       = "powershell-core"
  firefox_ignore_checksums          = "false"
  firefox_allow_empty_checksums     = "true"
  firefox_package_version           = "latest"
  firefox_package                   = "firefox"
  chrome_ignore_checksums           = "true"
  chrome_allow_empty_checksums      = "true"
  chrome_package_version            = "latest"
  chrome_package                    = "googlechrome"
  windows_client_vm_username        = "tester"
  windows_client_vm_logon_password  = random_password.password[3].result
  windows_client_vm_password        = random_password.password[4].result
  windows_client_vm_name            = "wcvm01"
  vm_count_total                    = [for i in range(var.windows_client_vm_count) : tostring(i)]
  windows_client_vm_config = {
    dev = {
      image_offer  = "Windows-11"
      image_sku    = "win11-22h2-pro"
      storage_type = "StandardSSD"
      vm_size      = "Standard_D2ds_v4"
    }
    staging = {
      image_offer  = "Windows-11"
      sku          = "win11-22h2-pro"
      storage_type = "StandardSSD"
      vm_size      = "Standard_D8ds_v4"
    }
  }
  linux_app_server_vm_config = {
    dev = {
      image_offer  = "0001-com-ubuntu-server-focal"
      image_sku    = "22_04-lts"
      storage_type = "StandardSSD"
      vm_size      = "Standard_D2ds_v4"
    }
    staging = {
      image_offer  = "0001-com-ubuntu-server-focal"
      image_sku    = "122_04-lts"
      storage_type = "StandardSSD"
      vm_size      = "Standard_D8ds_v4"
    }
  }
}

# ------------------------------------------------------------------------------------------------------
# Generate random passwords
# ------------------------------------------------------------------------------------------------------

resource "random_password" "password" {
  count       = 5
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 1
}

# ------------------------------------------------------------------------------------------------------
# Get secrets from the Key Vault
# ------------------------------------------------------------------------------------------------------

data "azurerm_key_vault" "existing" {
  name                = "kv-test-terraform"
  resource_group_name = "test-terraform-rg"
}

data "azurerm_key_vault_secret" "ado_pat_token" {
  name         = "ADO-PAT-TOKEN"
  key_vault_id = data.azurerm_key_vault.existing.id
}

data "azurerm_key_vault_secret" "ado_pool_name" {
  name         = "ADO-POOL-NAME"
  key_vault_id = data.azurerm_key_vault.existing.id
}

data "azurerm_key_vault_secret" "ado_account_name" {
  name         = "ADO-ACCOUNT-NAME"
  key_vault_id = data.azurerm_key_vault.existing.id
}

# ------------------------------------------------------------------------------------------------------
# Deploy the DevTestLab
# ------------------------------------------------------------------------------------------------------

resource "azurerm_dev_test_lab" "lab" {
  name                = var.lab_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_dev_test_virtual_network" "vnet" {
  name                = local.lab_virtual_network_name
  lab_name            = azurerm_dev_test_lab.lab.name
  resource_group_name = var.resource_group_name
  description         = "Virtual network for the DevTestLab"
  tags                = var.tags

  subnet {
    use_public_ip_address           = "Allow"
    use_in_virtual_machine_creation = "Allow"
  }
}

# ------------------------------------------------------------------------------------------------------
# Deploy linux and windows VMs with artifacts in the DevTestLab
# ------------------------------------------------------------------------------------------------------

resource "azapi_resource" "vm-linux-app-server" {
  count                     = var.deployment_type == "on-prem" ? 1 : 0
  type                      = "Microsoft.DevTestLab/labs/virtualmachines@2018-09-15"
  name                      = local.linux_app_server_vm_name
  location                  = var.location
  parent_id                 = azurerm_dev_test_lab.lab.id
  depends_on                = [azurerm_dev_test_lab.lab]
  tags                      = var.tags
  schema_validation_enabled = false # This is required for the schema to be accepted by the API
  body = {
    properties = {
      allowClaim = local.allow_claim
      artifacts = [
        {
          artifactId = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.DevTestLab/labs/%s/artifactSources/%s/artifacts/%s",
            data.azurerm_client_config.current.subscription_id,
            var.resource_group_name,
            var.lab_name,
            "public repo",
          "linux-apt-package"),
          artifactTitle = "APT Package"
          parameters = [{
            name  = "packages"
            value = local.apt_docker_compose_plugin_package
            },
            {
              name  = "update"
              value = local.apt_docker_compose_plugin_update
            },
            {
              name  = "options"
              value = local.apt_docker_compose_plugin_options
            }
          ]
        },
        {
          artifactId = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.DevTestLab/labs/%s/artifactSources/%s/artifacts/%s",
            data.azurerm_client_config.current.subscription_id,
            var.resource_group_name,
            var.lab_name,
            "public repo",
          "linux-installer-package"),
          artifactTitle = "Installer Package"
        },
        {
          artifactId = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.DevTestLab/labs/%s/artifactSources/%s/artifacts/%s",
            data.azurerm_client_config.current.subscription_id,
            var.resource_group_name,
            var.lab_name,
            "public repo",
          "linux-vsts-build-agent"),
          artifactTitle = "Script"
          "parameters" = [
            {
              "name"  = "adoAccount"
              "value" = data.azurerm_key_vault_secret.ado_account_name.value
            },
            {
              "name"  = "adoPat"
              "value" = data.azurerm_key_vault_secret.ado_pat_token.value
            },
            {
              "name"  = "adoPool"
              "value" = data.azurerm_key_vault_secret.ado_pool_name.value
            },
            {
              "name"  = "agentPath"
              "value" = local.ado_agent_path
            },
            {
              "name"  = "agentName"
              "value" = local.ado_agent_name
            }
          ]
        }
      ]

      galleryImageReference = {
        offer     = local.linux_app_server_vm_config[var.environment_name].image_offer
        publisher = "canonical"
        sku       = local.linux_app_server_vm_config[var.environment_name].image_sku
        osType    = "Linux"
        version   = "latest"
      }
      isAuthenticationWithSshKey = false
      disallowPublicIpAddress    = true

      labSubnetName       = azurerm_dev_test_virtual_network.vnet.subnet[0].name
      labVirtualNetworkId = azurerm_dev_test_virtual_network.vnet.id
      password            = local.vm_admin_password
      size                = local.linux_app_server_vm_config[var.environment_name].vm_size
      storageType         = local.linux_app_server_vm_config[var.environment_name].storage_type
      userName            = local.linux_app_server_vm_username

    }
  }
}

resource "azapi_resource" "vm-windows-client" {
  for_each                  = toset(local.vm_count_total) # This is required to create multiple VMs
  type                      = "Microsoft.DevTestLab/labs/virtualmachines@2018-09-15"
  name                      = "${local.windows_client_vm_name}-${each.key}"
  location                  = var.location
  parent_id                 = azurerm_dev_test_lab.lab.id
  depends_on                = [azurerm_dev_test_lab.lab]
  tags                      = var.tags
  schema_validation_enabled = false # This is required for the schema to be accepted by the API
  body = {
    properties = {
      allowClaim = local.allow_claim
      artifacts = [
        {
          artifactId = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.DevTestLab/labs/%s/artifactSources/%s/artifacts/%s",
            data.azurerm_client_config.current.subscription_id,
            var.resource_group_name,
            var.lab_name,
            "public repo",
          "windows-chocolatey"),
          artifactTitle = "Chocolatey"
          parameters = [{
            name  = "packages"
            value = local.chrome_package
            },
            {
              name  = "packageVersion"
              value = local.chrome_package_version
            },
            {
              name  = "allowEmptyChecksums"
              value = local.chrome_allow_empty_checksums
            },
            {
              name  = "ignoreChecksums"
              value = local.chrome_ignore_checksums
            }
          ]
        },
        {
          artifactId = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.DevTestLab/labs/%s/artifactSources/%s/artifacts/%s",
            data.azurerm_client_config.current.subscription_id,
            var.resource_group_name,
            var.lab_name,
            "public repo",
          "windows-chocolatey"),
          artifactTitle = "Chocolatey"
          parameters = [{
            name  = "packages"
            value = local.firefox_package
            },
            {
              name  = "packageVersion"
              value = local.firefox_package_version
            },
            {
              name  = "allowEmptyChecksums"
              value = local.firefox_allow_empty_checksums
            },
            {
              name  = "ignoreChecksums"
              value = local.firefox_ignore_checksums
            }
          ]
        },
        {
          artifactId = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.DevTestLab/labs/%s/artifactSources/%s/artifacts/%s",
            data.azurerm_client_config.current.subscription_id,
            var.resource_group_name,
            var.lab_name,
            "public repo",
          "windows-chocolatey"),
          artifactTitle = "Chocolatey"
          parameters = [
            {
              name  = "packages"
              value = local.ps_packages
            },
            {
              name  = "allowEmptyChecksums"
              value = local.ps_allow_empty_checksums
            },
            {
              name  = "ignoreChecksums"
              value = local.ps_ignore_checksums
            }
          ]
        },
        {
          artifactId = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.DevTestLab/labs/%s/artifactSources/%s/artifacts/%s",
            data.azurerm_client_config.current.subscription_id,
            var.resource_group_name,
            var.lab_name,
            "public repo",
          "windows-chocolatey"),
          artifactTitle = "Chocolatey"
          parameters = [
            {
              name  = "packages"
              value = local.az_packages
            },
            {
              name  = "allowEmptyChecksums"
              value = local.az_allow_empty_checksums
            },
            {
              name  = "ignoreChecksums"
              value = local.az_ignore_checksums
            }

          ]
        },
        {
          artifactId = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.DevTestLab/labs/%s/artifactSources/%s/artifacts/%s",
            data.azurerm_client_config.current.subscription_id,
            var.resource_group_name,
            var.lab_name,
            "public repo",
          "windows-vsts-build-agent"),
          artifactTitle = "VSTS Agent"
          parameters = [
            {
              name  = "vstsAccount"
              value = data.azurerm_key_vault_secret.ado_account_name.value
            },
            {
              name  = "vstsPassword"
              value = data.azurerm_key_vault_secret.ado_pat_token.value
            },
            {
              name  = "agentName"
              value = local.ado_agent_name
            },
            {
              name  = "agentNameSuffix"
              value = local.agent_name_suffix
            },
            {
              name  = "poolName"
              value = data.azurerm_key_vault_secret.ado_pool_name.value
            },
            {
              name  = "RunAsAutoLogon"
              value = local.run_as_auto_logon
            },
            {
              name  = "windowsLogonAccount"
              value = local.windows_logon_account
            },
            {
              name  = "windowsLogonPassword"
              value = local.windows_client_vm_logon_password
            },
            {
              name  = "driveLetter"
              value = local.driver_letter
            },
            {
              name  = "workDirectory"
              value = local.work_directory
            },
            {
              name  = "replaceAgent"
              value = local.replace_agent
            }

          ]
        }
      ]
      galleryImageReference = {
        offer     = local.windows_client_vm_config[var.environment_name].image_offer
        publisher = "microsoftwindowsdesktop"
        sku       = local.windows_client_vm_config[var.environment_name].image_sku
        osType    = "Windows"
        version   = "latest"
      }

      labSubnetName       = azurerm_dev_test_virtual_network.vnet.subnet[0].name
      labVirtualNetworkId = azurerm_dev_test_virtual_network.vnet.id
      password            = local.windows_client_vm_password
      size                = local.windows_client_vm_config[var.environment_name].vm_size
      storageType         = local.windows_client_vm_config[var.environment_name].storage_type
      userName            = local.windows_client_vm_username

    }
  }
}
