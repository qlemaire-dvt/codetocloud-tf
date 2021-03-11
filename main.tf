provider "azurerm" {
  features {}
}

module "servers" {
  count = var.server_count 
  source = "./server"

  trigram 	 = "${var.server_trigram}-${count.index}"
  location 	 = var.server_location
  prefix 	 = var.server_prefix
  admin_password = var.password
  default_user   = var.user
  osimage        = var.personal_image
  imagerg        = var.personal_image_rg
 
  #os_image = var.server_os_image

}
