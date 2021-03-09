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

