terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "2.6.1"
    }
  }
}

resource "azapi_resource" "devtestlab_artifact_source" {
  type      = "Microsoft.DevTestLab/labs/artifactsources@2018-09-15"
  name      = var.artifact_source_name
  parent_id = var.parent_id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      armTemplateFolderPath = var.arm_template_folder_path
      branchRef             = var.branch_ref
      displayName           = var.display_name
      folderPath            = var.folder_path
      securityToken         = var.security_token
      sourceType            = var.source_type
      status                = var.status
      uri                   = var.uri
    }
  }
}


resource "azapi_resource" "artifact" {
  type      = "Microsoft.DevTestLab/labs/artifactsources/artifacts@2018-09-15"
  for_each  = { for artifact in var.artifacts : artifact.name => artifact }
  name      = each.value.name
  parent_id = azapi_resource.devtestlab_artifact_source.id

  depends_on = [azapi_resource.devtestlab_artifact_source]
}
