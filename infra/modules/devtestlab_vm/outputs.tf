output "id" {
  description = "The resource ID of the created VM."
  value       = azapi_resource.vm.id
}

output "name" {
  description = "The name of the VM."
  value       = azapi_resource.vm.name
}

output "password_secret_name" {
  description = "The name of the secret in Azure Key Vault containing the VM's password."
  value = azurerm_key_vault_secret.vm_password_secret.name
}