# global variables 
variable "region" {
  type = string
}
variable "project" {
  type = string
}
variable "tags" {
  type = map(any)
}

# rds variables
variable "name" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

# credentials
variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}


variable "engine_version" {
  type    = string
  default = null
}

variable "disk_size" {
  type    = number
  default = 150

}




