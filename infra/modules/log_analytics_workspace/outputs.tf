output "id" {
  description = "Specifies the log analytics workspace id"
  value = azurerm_log_analytics_workspace.law.id
}

output "workspace_key" {
description = "Specifies the primary shared key of the log analytics workspace"
  value = azurerm_log_analytics_workspace.law.primary_shared_key
}

output "workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.id 
}

output "name" {
  description = "Specifies the name of the log analytics workspace"
  value = azurerm_log_analytics_workspace.law.name
}

output "primary_shared_key" {
  description = "Specifies the workspace key of the log analytics workspace"
  value = azurerm_log_analytics_workspace.law.primary_shared_key
  sensitive = true
}