variable "container_image" {
  type = string
}

variable "container_cpu" {
  type = number
}

variable "container_memory" {
  type = number
}

variable "container_port" {
  type = number
}

variable "dbusername" {
  type = string
}

variable "dbpassword" {
  type = string
}

variable "docdb_endpoint" {
  type = string
}

variable "service_desired_count" {
  type = number
}

variable "sg_ecs" {
  type = any
}

variable "private_subnets" {
  type = list
}

variable "alb_tg_arn" {
  type = string
}
