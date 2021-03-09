provider "azurerm" { 
  features {} 
} 

module "servers" {
  count = 1
  source = "./server"

  trigram = "sba-${count.index}"

}
