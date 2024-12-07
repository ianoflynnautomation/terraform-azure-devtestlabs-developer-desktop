
variable "environment_name" {
  description = "The name of the environment."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
  default     = "switzerlandnorth"
}

variable "windows_client_vm_count" {
  description = "The number of virtual machines to create."
  type        = number
  default     = 2
}

