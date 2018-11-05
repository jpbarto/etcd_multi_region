provider "aws" {
    region = "eu-west-2"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "azs" {
    type = "list"
}

variable "dns" {
    type = "map"

    default = {
        domain_name = "example.com"
    }
}