locals {
  vm_configs = {
    dev = {
      linux_default = {
        size         = "Standard_D2ds_v4"
        storage_type = "StandardSSD"
        image_reference = {
          publisher = "canonical"
          offer     = "0001-com-ubuntu-server-focal"
          sku       = "22_04-lts"
          osType    = "Linux"
          version   = "latest"
        }
      }
      windows_default = {
        size         = "Standard_D2ds_v4"
        storage_type = "StandardSSD"
        image_reference = {
          publisher = "microsoftwindowsdesktop"
          offer     = "Windows-11"
          sku       = "win11-22h2-pro"
          osType    = "Windows"
          version   = "latest"
        }
      }
    }
    staging = {
      linux_default = {
        size         = "Standard_D8ds_v4"
        storage_type = "StandardSSD"
        image_reference = {
          publisher = "canonical"
          offer     = "0001-com-ubuntu-server-focal"
          sku       = "22_04-lts"
          osType    = "Linux"
          version   = "latest"
        }
      }
      windows_default = {
        size         = "Standard_D8ds_v4"
        storage_type = "StandardSSD"
        image_reference = {
          publisher = "microsoftwindowsdesktop"
          offer     = "Windows-11"
          sku       = "win11-22h2-pro"
          osType    = "Windows"
          version   = "latest"
        }
      }
    }
  }

  # artifact_path_prefix = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.DevTestLab/labs/${var.lab_name}/artifactSources/public repo/artifacts"

  virtual_machines = {
    "linux-server" = {
      is_enabled     = var.deploy_linux_vm
      os_type        = "linux_default"
      admin_username = var.linux_vm_admin_username
      # artifacts = flatten([
      #   [
      #     {
      #       artifactId    = "${local.artifact_path_prefix}/linux-apt-package"
      #       artifactTitle = "APT Package"
      #       parameters    = [{ name = "packages", value = "docker-compose" }, { name = "update", value = "true" }]
      #     },
      #     {
      #       artifactId    = "${local.artifact_path_prefix}/linux-vsts-build-agent"
      #       artifactTitle = "VSTS Agent"
      #       parameters = [
      #         { name = "adoAccount", value = var.ado_account_name },
      #         { name = "adoPat", value = data.azurerm_key_vault_secret.ado_pat.value },
      #         { name = "adoPool", value = var.ado_pool_name },
      #         { name = "agentPath", value = "/agent" },
      #         { name = "agentName", value = "linux-server-01" }
      #       ]
      #     }
      #   ],
      #   # --- Conditionally add the AMA artifact for Linux ---
      #   # NOTE: Replace 'My-Custom-Repo' with the name of your artifact source in the lab.
      #   [
      #     for item in [1] : {
      #       artifactId    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.DevTestLab/labs/${var.lab_name}/artifactSources/My-Custom-Repo/artifacts/ama-installer-linux"
      #       artifactTitle = "Install Azure Monitor Agent (AMA) for Linux"
      #       parameters    = []
      #     } if var.enable_log_analytics
      #   ]
      # ])
    },
    "win-client" = {
      is_enabled     = var.windows_vm_count >= 1
      os_type        = "windows_default"
      admin_username = var.windows_vm_admin_username
      # artifacts = flatten([
      #   # --- List of standard artifacts ---
      #   [
      #     {
      #       artifactId    = "${local.artifact_path_prefix}/windows-chocolatey"
      #       artifactTitle = "Chocolatey Packages"
      #       parameters    = [{ name = "packages", value = "googlechrome firefox powershell-core azure-cli" }]
      #     },
      #     {
      #       artifactId    = "${local.artifact_path_prefix}/windows-vsts-build-agent"
      #       artifactTitle = "VSTS Agent"
      #       parameters = [
      #         { name = "vstsAccount", value = var.ado_account_name },
      #         { name = "vstsPat", value = data.azurerm_key_vault_secret.ado_pat.value },
      #         { name = "poolName", value = var.ado_pool_name }
      #       ]
      #     }
      #   ],
      #   # --- Conditionally add the AMA artifact for Windows ---
      #   # NOTE: Replace 'My-Custom-Repo' with the name of your artifact source in the lab.
      #   [
      #     for item in [1] : {
      #       artifactId    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.DevTestLab/labs/${var.lab_name}/artifactSources/My-Custom-Repo/artifacts/ama-installer-windows"
      #       artifactTitle = "Install Azure Monitor Agent (AMA) for Windows"
      #       parameters    = []
      #     } if var.enable_log_analytics
      #   ]
      # ])
    }
  }
}