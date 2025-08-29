output "dev_test_lab_id" {
  description = "The resource ID of the created DevTest Lab."
  value       = module.dev_test_lab.id
}

output "dev_test_lab_name" {
  description = "The name of the DevTest Lab."
  value       = module.dev_test_lab.name
}

output "key_vault_name" {
  description = "The name of the Key Vault used for storing secrets."
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = module.key_vault.uri
}

output "vm_passwords_secret_names" {
  description = "A map of VM names to the names of their password secrets in Key Vault."
  value = {
    for name, vm in module.dev_test_lab_vms :
    name => vm.password_secret_name
  }
}