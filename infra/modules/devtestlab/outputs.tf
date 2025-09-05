output "id" {
  description = "The resource ID of the DevTestLab."
  value       = azapi_resource.dtl.id
}

output "name" {
  description = "The name of the DevTestLab."
  value       = azapi_resource.dtl.name
}

output "vnet_id" {
  description = "The resource ID of the lab's virtual network."
  value       = azapi_resource.vnet.id
}


output "subnet_name" {
  description = "The name of the first subnet in the lab's VNet."
  value       = azapi_resource.vnet.body.properties.subnetOverrides[0].labSubnetName
}