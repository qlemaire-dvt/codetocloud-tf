resource "azurerm_resource_group" "main" {
  #name     = "${var.prefix}-resources-${var.trigram}"
  name     = "${var.prefix}-resources" #quick fix to have all the vm's in the same resource group
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network-${var.trigram}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip-${var.trigram}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic1-${var.trigram}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "internal" {
  name                      = "${var.prefix}-nic2-${var.trigram}"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "workshop-trafic" {
  name                = "workshop-${var.trigram}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "workshop-ssh" {
  name                        = "workshop-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.workshop-trafic.name
}

resource "azurerm_network_security_rule" "workshop-web" {
  name                        = "workshop-web"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.workshop-trafic.name
}

resource "azurerm_network_security_rule" "workshop-api" {
  name                        = "workshop-api"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3001"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.workshop-trafic.name
}

#data "azurerm_resource_group" "image_rg" {
#  name		= "CodeToCloud-QLE"
#}
#
#data "azurerm_image" "os_image" {
#  name			= "ubuntu-workshop-image-v1"
#  resource_group_name	= data.azurerm_resource_group.image_rg.name
#  }

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.internal.id
  network_security_group_id = azurerm_network_security_group.workshop-trafic.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm-${var.trigram}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B2s"
  admin_username                  = "adminuser"
  admin_password                  = "C0deToCloud!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
    azurerm_network_interface.internal.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

  source_image_reference {
    id = "/subscriptions/4760579d-6e21-4a51-988b-54af405584f4/resourceGroups/CodeToCloud-QLE/providers/Microsoft.Compute/images/ubuntu-workshop-image-v1"
  }
}

output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = azurerm_public_ip.pip.id
}
