
variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment."
  type        = string
  default     = "dev"
}

variable "deployment_type" {
  description = "The type of deployment."
  type        = string
  default     = "on-prem"

  validation {
    condition     = var.deployment_type == "on-prem" || var.deployment_type == "saas"
    error_message = "The deployment type must be either 'on-prem' or 'saas'."
  }
}

variable "lab_name" {
  type    = string
  default = "DevTestLab01"
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}


variable "windows_client_vm_count" {
  description = "The number of virtual machines to create."
  type        = number

  validation {
    condition     = var.windows_client_vm_count > 0 && var.windows_client_vm_count <= 10
    error_message = "The number of virtual machines must be greater than 0 and less than or equal to 10."
  }
}





