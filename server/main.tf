resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources-${var.trigram}"
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

data "azurerm_resource_group" "image_rg" {
  name          = var.imagerg
}

data "azurerm_image" "os_image" {
  name                  = var.osimage
  resource_group_name	= data.azurerm_resource_group.image_rg.name
  }

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.internal.id
  network_security_group_id = azurerm_network_security_group.workshop-trafic.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm-${var.trigram}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B2s"
  admin_username                  = var.default_user
  admin_password                  = var.admin_password
  source_image_id 		  = data.azurerm_image.os_image.id 
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
    azurerm_network_interface.internal.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  provisioner "remote-exec" {
    inline = ["sudo usermod -aG docker ${var.default_user}"]

    connection {
      type	= "ssh"
      user	= var.default_user
      password 	= var.admin_password
      host 	= azurerm_linux_virtual_machine.main.public_ip_address
    }
  }
  
}

output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = azurerm_public_ip.pip.*.ip_address
}

output "public_from_vm_id" {
  description = "id of the public ip from vm"
  value       = azurerm_linux_virtual_machine.main.public_ip_address
}

output "image_id" {
  description = "id of image"
  value       = data.azurerm_image.os_image.id
}

#resource "azurerm_managed_disk" "data" {
#  name                 = "${azurerm_linux_virtual_machine.main.name}-disk1"
#  location             = azurerm_resource_group.main.location
#  resource_group_name  = azurerm_resource_group.main.name
#  storage_account_type = "Standard_LRS"
#  create_option        = "Empty"
#  disk_size_gb         = 10
#}
#
#resource "azurerm_virtual_machine_data_disk_attachment" "data" {
#  managed_disk_id    = azurerm_managed_disk.data.id
#  virtual_machine_id = azurerm_linux_virtual_machine.main.id
#  lun                = "10"
#  caching            = "None"
#}
