provider "azurerm" { 
  features {} 
} 

module "servers" {
  count = 4
  source = "./server"

  trigram = "sba-${count.index}"

}
