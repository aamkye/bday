variable "aws-profile" {
  type    = string
  default = "bday"
}

variable "availability_zones" {
  type    = list
  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "private_subnets" {
  type    = list
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]
}

variable "container_image" {
  type    = string
  default = "lodufqa/bday:abd0c10"
}

variable "service_desired_count" {
  type    = number
  default = 3
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "container_cpu" {
  type    = number
  default = 256
}

variable "container_memory" {
  type    = number
  default = 512
}

variable "health_check_path" {
  type = string
  default = "/health"
}

variable "r53_zone_id" {
  type = string
  default = "Z06376172LDC1GHT4YXA5"
}

variable "r53_record_name" {
  type = string
  default = "bday.ak95.io"
}

variable "dbusername" {
  type    = string
  sensitive = true
}

variable "dbpassword" {
  type    = string
  sensitive = true
}

variable "alb_tls_cert_arn" {
  type    = string
  sensitive = true
}
