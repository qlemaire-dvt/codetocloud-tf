variable "server_prefix" {
  description = "The prefix which should be used for all resources in this example"
  type = string
  default = "LAB-git-workshop"
}

variable "server_location" {
  description = "The Azure Region in which all resources in this example should be created."
  type = string
  default = "West Europe"
}

variable "server_trigram" {
    description = "This prefix consists of 3 letters, 1st one of your first name, then the 2 first letters of your last name"
    type = string
    default = "sba"
}

variable "server_os_image" {
  description = "self made image"
  type = string
  default = "/subscriptions/4760579d-6e21-4a51-988b-54af405584f4/resourceGroups/CodeToCloud-QLE/providers/Microsoft.Compute/images/ubuntu-workshop-image-v1"
}

variable "server_count" {
  description = "amount of servers"
  type = number
  default = 1
}

variable "user" {
  description = "User that will be created and added to Docker group"
  type = string
  default = "default-user"
}

variable "password" {
  description = "Password for admin user"
  type = string
  default = "changeme"
}

variable "personal_image" {
  description = "name of the azure image"
  type = string
  default = "ubuntu-workshop-image-v3"
}
variable "personal_image_rg" {
  description = "name of iamge resource group"
  type = string
  default = "CodeToCloud-QLE"
}
