variable "private_subnets" {
  type = list
}

variable "dbusername" {
  type      = string
  sensitive = true
}

variable "dbpassword" {
  type      = string
  sensitive = true
}

variable "availability_zones" {
  type = list
}

variable "mongo_sg" {
  type = any
}
