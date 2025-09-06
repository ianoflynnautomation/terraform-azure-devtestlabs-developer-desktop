variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
  default     = "switzerlandnorth"
}

variable "environment" {
  description = "The deployment environment name (e.g., 'dev', 'staging')."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging"], var.environment)
    error_message = "The environment must be either 'dev' or 'staging'."
  }
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "linux_vm_count" {
  description = "Number of Linux VMs to create."
  type        = number
  default     = 1
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

variable "dtl_storage_type" {
  description = "The storage type for the Dev Test Lab. Can be 'Standard' or 'Premium'."
  type        = string
  default     = "Premium"
}

variable "dtl_announcement" {
  description = "Configuration for the lab announcement banner. Set to null to use the default."
  type        = any
  default     = null
}

variable "dtl_subnet_overrides" {
  description = "A list of subnet configurations for the virtual network. Set to null to use the default."
  type        = any
  default     = null
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

variable "key_vault_enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault."
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "(Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault."
  type        = bool
  default     = true
}

variable "key_vault_enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  type        = bool
  default     = true
}

variable "key_vault_purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault?"
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  type        = number
  default     = 30
}

variable "key_vault_bypass" {
  description = "(Required) Specifies which traffic can bypass the network rules. Possible values are AzureServices and None."
  type        = string
  default     = "AzureServices"
  validation {
    condition     = contains(["AzureServices", "None"], var.key_vault_bypass)
    error_message = "The value of the bypass property of the key vault is invalid."
  }
}

variable "key_vault_default_action" {
  description = "(Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny."
  type        = string
  default     = "Allow"
  validation {
    condition     = contains(["Allow", "Deny"], var.key_vault_default_action)
    error_message = "The value of the default action property of the key vault is invalid."
  }
}

variable "vm_vnet_address_space" {
  description = "Specifies the address space of the virtual virtual network"
  default     = ["10.0.0.0/16"]
  type        = list(string)
}


variable "vm_subnet_address_prefix" {
  description = "Specifies the address prefix of the jumbox subnet"
  default     = ["10.0.0.0/20"]
  type        = list(string)
}

variable "bastion_subnet_address_prefix" {
  description = "Specifies the address prefix of the firewall subnet"
 default     = ["10.0.16.0/24"]
  type        = list(string)
}