variable "public_subnets" {
  type = list
}

variable "alb_sg" {
  type = any
}

variable "vpc_id" {
  type = string
}

variable "alb_tls_cert_arn" {
  type = string
}

variable "container_port" {
  type = number
}

variable "health_check_path" {
  type = string
}
