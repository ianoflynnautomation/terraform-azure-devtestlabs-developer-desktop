output "LAB_NAME" {
  value     = azurerm_dev_test_lab.lab.name
  sensitive = false
}

output "LAB_VIRTUAL_NETWORK_NAME" {
  value     = azurerm_dev_test_virtual_network.vnet.name
  sensitive = false
}

output "LAB_WINDOWS_CLIENT_VM_ID" {
  value     = [for vm in azapi_resource.vm-windows-client : vm.id]
  sensitive = false
}

output "LAB_WINDOWS_CLIENT_VM_NAME" {
  value     = [for vm in azapi_resource.vm-windows-client : vm.name]
  sensitive = false
}

output "LINUX_APP_SERVER_VM_ID" {
  value     =   [for vm in azapi_resource.vm-linux-app-server : vm.id] 
  sensitive = false
}

output "LINUX_APP_SERVER_VM_NAME" {
  value     = [for vm in azapi_resource.vm-linux-app-server : vm.name]
  sensitive = false
}
