iresource "azurerm_lb" "this" {
  name                = var.lb_name
  location            = var.lb_locaion
  resource_group_name = var.lb_resource_group_name
  sku                 = var.lb_sku

  frontend_ip_configuration {
    name                 = var.lb_frontend_ip_configuration_name
    public_ip_address_id = var.lb_public_ip_name
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  loadbalancer_id = azurerm_lb.this.id
  name            = var.lb_backend_address_pool_name
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  network_interface_id    = var.lb_backend_interface_id
  ip_configuration_name   = var.lb_backend_ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
}

output "lb_backend_address_pool_id" {
  value = azurerm_lb_backend_address_pool.this.id
}

variable "lb_backend_interface_id" {
  type = string
}

variable "lb_backend_ip_configuration_name" {
  type = string
}

variable "lb_locaion" {
  type = string
}

variable "lb_name" {
  type = string
}

variable "lb_resource_group_name" {
  type = string
}

variable "lb_sku" {
  type = string
}

variable "lb_backend_address_pool_name" {
  type = string
}

variable "lb_public_ip_name" {
  type = string
}

variable "lb_frontend_ip_configuration_name" {
  type = string
}