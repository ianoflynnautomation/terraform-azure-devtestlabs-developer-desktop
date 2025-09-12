output "id" {
  description = "The resource ID of the DevTestLab."
  value       = azapi_resource.dtl.id
}

output "name" {
  description = "The name of the DevTestLab."
  value       = azapi_resource.dtl.name
}
