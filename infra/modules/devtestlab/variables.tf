variable "lab_name" {
  description = "The name for the DevTestLab."
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name for the lab."
  type        = string
}

variable "location" {
  description = "The Azure region for the lab."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "lab_virtual_network_name" {
  description = "Name for the lab's virtual network."
  type        = string
}

variable "lab_storage_type" {
  description = "The storage type for the lab. Can be 'Standard' or 'Premium'."
  type        = string
  default     = "Premium"
  validation {
    condition     = contains(["Standard", "Premium"], var.lab_storage_type)
    error_message = "The lab storage type must be either 'Standard' or 'Premium'."
  }
}

variable "premium_data_disks" {
  description = "The setting to enable or disable premium data disks in the lab. Can be 'Enabled' or 'Disabled'."
  type        = string
  default     = "Disabled"
}


variable "announcement" {
  description = "Configuration for the lab announcement banner."
  type = object({
    enabled  = optional(string, "Disabled")
    title    = optional(string)
    markdown = optional(string)
  })
  default = {}
}

variable "support" {
  description = "Configuration for the lab's internal support contact information."
  type = object({
    enabled  = optional(string, "Disabled")
    markdown = optional(string)
  })
  default = {}
}


variable "subnet_overrides" {
  description = "A list of subnet configurations for the virtual network."
  type = list(object({
    labSubnetName                = string
    useInVmCreationPermission    = string
    usePublicIpAddressPermission = string
    sharedPublicIpAddressConfiguration = optional(object({
      allowedPorts = list(object({
        transportProtocol = string
        backendPort       = number
      }))
    }))
    virtualNetworkPoolName = optional(string)
  }))
  default = [
    {
      labSubnetName                = "vnet-dtl-dev-swnSubnet"
      useInVmCreationPermission    = "Allow"
      usePublicIpAddressPermission = "Deny"
      sharedPublicIpAddressConfiguration = {
        allowedPorts = [
          {
            transportProtocol = "Tcp"
            backendPort       = 3389
          },
          {
            transportProtocol = "Tcp"
            backendPort       = 22
          }
        ]
      }
      virtualNetworkPoolName = null
    }
  ]
}

variable "allowed_subnets" {
  description = "A list of allowed subnets for the virtual network."
  type = list(object({
    allowPublicIp = string
    labSubnetName = string
    resourceId    = string
  }))
  default = [
    {
      allowPublicIp = "Deny"
      labSubnetName = "default"
      resourceId    = ""
    }
  ]
}