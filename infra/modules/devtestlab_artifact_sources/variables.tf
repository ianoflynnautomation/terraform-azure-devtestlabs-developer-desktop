variable "artifact_source_name" {
  description = "The name of the artifact source in the DevTest Lab."
  type        = string
  validation {
    condition     = length(var.artifact_source_name) > 0 && length(var.artifact_source_name) <= 100
    error_message = "The artifact source name must be between 1 and 100 characters."
  }
}

variable "parent_id" {
  description = "The resource ID of the parent DevTest Lab (e.g., /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.DevTestLab/labs/{labName})."
  type        = string
  validation {
    condition     = length(var.parent_id) > 0
    error_message = "The parent_id must be a valid resource ID."
  }
}

variable "location" {
  description = "The Azure region where the artifact source is located."
  type        = string
  validation {
    condition     = length(var.location) > 0
    error_message = "The location must be a valid Azure region."
  }
}

variable "tags" {
  description = "Tags to apply to the artifact source."
  type        = map(string)
  default     = {}
}

variable "arm_template_folder_path" {
  description = "The folder path in the source control repository containing ARM templates."
  type        = string
  default     = ""
  validation {
    condition     = length(var.arm_template_folder_path) <= 255
    error_message = "The ARM template folder path must be 255 characters or less."
  }
}

variable "branch_ref" {
  description = "The branch reference in the source control repository (e.g., refs/heads/main for GitHub)."
  type        = string
  default     = ""
  validation {
    condition     = length(var.branch_ref) <= 255
    error_message = "The branch reference must be 255 characters or less."
  }
}

variable "display_name" {
  description = "The display name for the artifact source."
  type        = string
  default     = ""
  validation {
    condition     = length(var.display_name) <= 255
    error_message = "The display name must be 255 characters or less."
  }
}

variable "folder_path" {
  description = "The folder path in the source control repository containing artifacts."
  type        = string
  default     = ""
  validation {
    condition     = length(var.folder_path) <= 255
    error_message = "The folder path must be 255 characters or less."
  }
}

variable "security_token" {
  description = "The security token (e.g., Personal Access Token) for accessing the source control repository. Should be stored in a Key Vault for security."
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition     = length(var.security_token) <= 255
    error_message = "The security token must be 255 characters or less."
  }
}

variable "source_type" {
  description = "The type of the artifact source. Can be 'GitHub', 'VsoGit', or 'StorageAccount'."
  type        = string
  default     = "GitHub"
  validation {
    condition     = contains(["GitHub", "VsoGit", "StorageAccount"], var.source_type)
    error_message = "The source type must be 'GitHub', 'VsoGit', or 'StorageAccount'."
  }
}

variable "status" {
  description = "The status of the artifact source. Can be 'Enabled' or 'Disabled'."
  type        = string
  default     = "Enabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.status)
    error_message = "The status must be 'Enabled' or 'Disabled'."
  }
}

variable "uri" {
  description = "The URI of the source control repository (e.g., https://github.com/myrepo for GitHub)."
  type        = string
  default     = ""
  validation {
    condition     = length(var.uri) <= 2048
    error_message = "The URI must be 2048 characters or less."
  }
}