variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  type = string
  default = "LAB-git-workshop"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type = string
  default = "West Europe"
}

variable "trigram" {
    description = "This prefix consists of 3 letters, 1st one of your first name, then the 2 first letters of your last name"
    type = string
    default = "sba"
}

variable "os_image" {
  description = "self made image"
  type = string
  default = "/subscriptions/4760579d-6e21-4a51-988b-54af405584f4/resourceGroups/CodeToCloud-QLE/providers/Microsoft.Compute/images/ubuntu-workshop-image-v1"
}

variable "default_user" {
  description = "User that will be created and added to Docker group"
  type = string
  default = "workshop-user"
}

variable "admin_password" {
  description = "Password for admin user"
  type = string
  default = "C0deToCloud!"
}

variable "osimage" {
  description = "name of the azure image"
  type = string
  default = "ubuntu-workshop-image-v3"
}
variable "imagerg" {
  description = "name of iamge resource group"
  type = string
  default = "CodeToCloud-QLE"
}

