locals {
  workload = "dtl"

  location_map = {
    "switzerlandnorth" = "swn"
    "westeurope"       = "weu"
    "northeurope"      = "neu"
  }
  location_short = local.location_map[var.location]

  resource_group_name          = "rg-${local.workload}-${var.environment}-${local.location_short}"
  log_analytics_workspace_name = "la-${local.workload}-${var.environment}-${local.location_short}"
  key_vault_name               = "kv-${local.workload}-${var.environment}-${local.location_short}"
  dev_test_lab_name            = "dtl-${local.workload}-${var.environment}-${local.location_short}"
  dev_test_lab_vnet_name       = "vnet-${local.workload}-${var.environment}-${local.location_short}"

  vm_configs = {
    dev = {
      linux_default = {
        size         = "Standard_D4as_v5"
        storage_type = "StandardSSD"
        image_reference = {
          publisher = "canonical"
          offer     = "0001-com-ubuntu-minimal-jammy"
          sku       = "minimal-22_04-lts-gen2"
          osType    = "Linux"
          version   = "latest"
        }
      }
      windows_default = {
        size         = "Standard_D4as_v5"
        storage_type = "StandardSSD"
        image_reference = {
          publisher = "MicrosoftWindowsDesktop"
          offer     = "windows-11"
          sku       = "win11-24h2-pro"
          osType    = "Windows"
          version   = "latest"
        }
      }
    }
    staging = {
      linux_default = {
        size         = "Standard_D8as_v5"
        storage_type = "PremiumSSD"
        image_reference = {
          publisher = "canonical"
          offer     = "0001-com-ubuntu-minimal-jammy"
          sku       = "minimal-22_04-lts-gen2"
          osType    = "Linux"
          version   = "latest"
        }
      }
      windows_default = {
        size         = "Standard_D8as_v5"
        storage_type = "PremiumSSD"
        image_reference = {
          publisher = "MicrosoftWindowsDesktop"
          offer     = "windows-11"
          sku       = "win11-24h2-pro"
          osType    = "Windows"
          version   = "latest"
        }
      }
    }
  }

  vm_definitions = {
    linux = {
      base_name      = "linux-server"
      os_type        = "linux_default"
      admin_username = var.linux_vm_admin_username
    },
    windows = {
      base_name      = "win-client"
      os_type        = "windows_default"
      admin_username = var.windows_vm_admin_username
    }
  }

  linux_vms = {
    for i in range(var.linux_vm_count) :
    format("%s-%02d", local.vm_definitions.linux.base_name, i + 1) => {
      os_type        = local.vm_definitions.linux.os_type
      admin_username = local.vm_definitions.linux.admin_username
    }
  }

  windows_vms = {
    for i in range(var.windows_vm_count) :
    format("%s-%02d", local.vm_definitions.windows.base_name, i + 1) => {
      os_type        = local.vm_definitions.windows.os_type
      admin_username = local.vm_definitions.windows.admin_username
    }
  }

  virtual_machines = merge(local.linux_vms, local.windows_vms)

  tags = {
    Environment = var.environment
    Workload    = local.workload
  }

  default_dtl_announcement = {
    enabled  = "Enabled"
    title    = "Welcome to the new Dev Lab!"
    markdown = "Please keep costs in mind. All VMs will be shut down at 7 PM CET."
  }

  default_dtl_subnet_overrides = [{
    labSubnetName                = "${local.dev_test_lab_vnet_name}Subnet"
    useInVmCreationPermission    = "Allow"
    usePublicIpAddressPermission = "Default"
  }]
}
