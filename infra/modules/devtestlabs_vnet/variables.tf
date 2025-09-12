variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name for the lab's virtual network registration."
  type        = string
}

variable "parent_id" {
  description = "parent id of the resource"
  type        = string
}


variable "location" {
  description = "The Azure region for the lab."
  type        = string
}

variable "externalProviderResourceId"{
    description = "The resource ID of the associated Azure virtual network"
    type = string 
}

variable "subnet_overrides" {
  description = "A list of subnet configurations for the virtual network."
  type = list(object({
    resourceId    = string
    labSubnetName = string
    sharedPublicIpAddressConfiguration = optional(object({
      allowedPorts = list(object({
        transportProtocol = string
        backendPort       = number
      }))
    }))
    useInVmCreationPermission    = string
    usePublicIpAddressPermission = string
    # virtualNetworkPoolName = optional(string)

  }))

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
