output "id" {
  description = "The resource ID of the lab's virtual network."
  value       = azapi_resource.vnet.id
}

output "name" {
  description = "The resource ID of the lab's virtual network."
  value       = azapi_resource.vnet.name
}

output "subnets" {
  description = "A map of the subnets associated with the lab's virtual network, keyed by subnet name."
  value = {
    for s in azapi_resource.vnet.body.properties.allowedSubnets : s.labSubnetName => {
      id   = s.resourceId
      name = s.labSubnetName
    }
  }
}
