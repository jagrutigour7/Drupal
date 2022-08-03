
module "DBmodule" {
  source   = "./DBmodule"
  location = var.location

}

module "Webmodule" {
  source   = "./Webmodule"
  location = var.location
}


resource "azurerm_resource_group" "myazrg" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_resource_group.myazrg]
}

