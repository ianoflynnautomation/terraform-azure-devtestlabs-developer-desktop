output name {
  description = "Specifies the name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output id {
  description = "Specifies the resource id of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnets" {
  description = "A map of the subnets associated with the virtual network, keyed by subnet name."
  value = {
    for subnet in azurerm_subnet.subnet : subnet.name => {
      id   = subnet.id
      name = subnet.name
    }
  }
}