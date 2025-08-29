variable "resource_group_name" {
  description = "The name of the resource group where resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "environment" {
  description = "The deployment environment name (e.g., 'dev', 'staging')."
  type        = string
  validation {
    condition     = contains(["dev", "staging"], var.environment)
    error_message = "The environment must be either 'dev' or 'staging'."
  }
}

variable "lab_name" {
  description = "The base name for the DevTestLab."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "deploy_linux_vm" {
  description = "Flag to control the deployment of the Linux VM."
  type        = bool
  default     = true
}

variable "linux_vm_admin_username" {
  description = "Admin username for the Linux VM."
  type        = string
  default     = "linuxadmin"
}

variable "windows_vm_count" {
  description = "Number of Windows VMs to create."
  type        = number
  default     = 1
}

variable "windows_vm_admin_username" {
  description = "Admin username for the Windows VMs."
  type        = string
  default     = "winadmin"
}

variable "ado_account_name" {
  description = "Azure DevOps account name for agent configuration."
  type        = string
}

variable "ado_pool_name" {
  description = "Azure DevOps agent pool name for agent configuration."
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Specifies the name of the log analytics workspace"
  default     = "TestWorkspace"
  type        = string
}

variable "solution_plan_map" {
  description = "Specifies solutions to deploy to log analytics workspace"
  default = {
    ContainerInsights = {
      publisher = "Microsoft"
      product   = "OMSGallery/ContainerInsights"
    }
  }
  type = map(any)
}

variable "enable_log_analytics" {
  description = "If true, the Log Analytics agent will be installed on the VM."
  type        = bool
  default     = false
}

variable "storage_account_kind" {
  description = "(Optional) Specifies the account kind of the storage account"
  default     = "StorageV2"
  type        = string

  validation {
    condition     = contains(["Storage", "StorageV2"], var.storage_account_kind)
    error_message = "The account kind of the storage account is invalid."
  }
}

variable "storage_account_replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = "LRS"
  type        = string

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.storage_account_replication_type)
    error_message = "The replication type of the storage account is invalid."
  }
}

variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  default     = "Standard"
  type        = string

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}

variable "container_name" {
  description = "(Required) Specifies the name of the container that contains the custom script."
  type        = string
  default     = "scripts"
}