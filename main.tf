provider "azurerm" {
  features {}
}

module "servers" {
  count = var.server_count 
  source = "./server"

  trigram = "${var.server_trigram}-${count.index}"
  location = var.server_location
  prefix = var.server_prefix
 
  #os_image = var.server_os_image

}
