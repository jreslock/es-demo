variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "private_zone_name" {
  description = "Set via output from the dns module"
}

variable "private_1a_cidr" {}
variable "private_1b_cidr" {}
variable "private_1c_cidr" {}
variable "public_1a_cidr" {}
variable "public_1b_cidr" {}
variable "public_1c_cidr" {}
