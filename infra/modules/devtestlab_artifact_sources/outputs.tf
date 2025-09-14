output "id" {
  description = "The resource ID of the artifact source."
  value       = azapi_resource.devtestlab_artifact_source.id
}

output "name" {
  description = "The name of the artifact source."
  value       = azapi_resource.devtestlab_artifact_source.name
}

output "source_type" {
  description = "The type of the artifact source (e.g., GitHub, VsoGit)."
  value       = azapi_resource.devtestlab_artifact_source.body.properties.sourceType
}

output "uri" {
  description = "The URI of the artifact source repository."
  value       = azapi_resource.devtestlab_artifact_source.body.properties.uri
}

output "status" {
  description = "The status of the artifact source (Enabled or Disabled)."
  value       = azapi_resource.devtestlab_artifact_source.body.properties.status
}

output "artifact_ids" {
  description = "The resource IDs of the artifacts."
  value       = { for k, v in azapi_resource.artifact : k => v.id }
}
