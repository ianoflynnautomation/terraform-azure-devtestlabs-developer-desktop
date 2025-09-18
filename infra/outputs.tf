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

