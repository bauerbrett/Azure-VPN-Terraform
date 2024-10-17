module "vm1" {
  source              = "./modules/azure_vm"
  vm_name             = "windowstestVM1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_size             = "Standard_B1s"
  
  image_publisher     = "MicrosoftWindowsServer"
  image_offer         = "WindowsServer"
  image_sku           = "2019-Datacenter"
  
  admin_username      = "testadmin"
  admin_password      = "Password1234!"  # Replace with a secure password. use env variables or a secrets manager.
  subnet_id           = azurerm_subnet.spk1_vm_subnet.id
  tags = {
    environment = "dev"
  }
}
module "vm2" {
  source              = "./modules/azure_vm"
  vm_name             = "windowstestVM2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_size             = "Standard_B1s"
  
  image_publisher     = "MicrosoftWindowsServer"
  image_offer         = "WindowsServer"
  image_sku           = "2019-Datacenter"
  
  admin_username      = "testadmin"
  admin_password      = "Password1234!"  # Replace with a secure password. use env variables or a secrets manager.
  subnet_id           = azurerm_subnet.spk2_vm_subnet.id
  tags = {
    environment = "dev"
  }
}