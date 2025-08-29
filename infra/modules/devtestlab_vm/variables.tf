variable "vm_name" {
  description = "Name of the virtual machine."
  type        = string
}

variable "location" {
  description = "Azure region for the VM."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the VM."
  type        = map(string)
  default     = {}
}

variable "lab_id" {
  description = "The resource ID of the parent DevTest Lab."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the lab resides."
  type        = string
}

variable "lab_vnet_id" {
  description = "The resource ID of the lab's virtual network."
  type        = string
}

variable "lab_subnet_name" {
  description = "The name of the subnet to deploy the VM into."
  type        = string
}

variable "gallery_image_reference" {
  description = "An object defining the gallery image to use for the VM."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    osType    = string
    version   = string
  })
}

variable "vm_size" {
  description = "The size (SKU) of the virtual machine."
  type        = string
}

variable "storage_type" {
  description = "The storage type for the VM's OS disk."
  type        = string
}

variable "admin_username" {
  description = "The admin username for the VM."
  type        = string
}

variable "artifacts" {
  description = "A list of artifact objects to apply to the VM during creation."
  type        = list(any)
  default     = []
}

variable "key_vault_id" {
  description = "The resource ID of the Azure Key Vault to store the VM password."
  type        = string
}

variable "enable_log_analytics" {
  description = "If true, the Log Analytics agent will be installed on the VM."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The Workspace ID of the Log Analytics Workspace."
  type        = string
  default     = null
}

variable "log_analytics_workspace_primary_key" {
  description = "The Primary Key of the Log Analytics Workspace."
  type        = string
  default     = null
  sensitive   = true
}