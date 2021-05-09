variable "cidr" {
  type    = string
}

variable "availability_zones" {
  type    = list
}

variable "public_subnets" {
  type    = list
}

variable "private_subnets" {
  type    = list
}
