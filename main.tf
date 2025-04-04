module "loadbalancer" {
  source                            = "./module/lb"
  lb_locaion                        = azurerm_resource_group.example.location
  lb_name                           = "example-lb"
  lb_resource_group_name            = azurerm_resource_group.example.name
  lb_sku                            = "Standard"
  lb_backend_address_pool_name      = "acctestpool"
  lb_public_ip_name                 = azurerm_public_ip.example.id
  lb_frontend_ip_configuration_name = "primary"
  lb_backend_interface_id           = azurerm_network_interface.example.id
  lb_backend_ip_configuration_name  = "internal"
}

resource "azurerm_resource_group" "example" {
  name     = "lb-test-resources"
  location = "westus2"
}

resource "azurerm_virtual_network" "example" {
  name                = "lb-test-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

import {
  to = module.loadbalancer.azurerm_network_interface_backend_address_pool_association.this
  id = "/subscriptions/6e7476dc-c6a7-443f-a420-ef2d0e3ea6d8/resourceGroups/lb-test-resources/providers/Microsoft.Network/networkInterfaces/example-nic/ipConfigurations/internal|/subscriptions/6e7476dc-c6a7-443f-a420-ef2d0e3ea6d8/resourceGroups/lb-test-resources/providers/Microsoft.Network/loadBalancers/example-lb/backendAddressPools/acctestpool"
}