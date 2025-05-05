variable "region" {
  type = string
}

variable "os_details" {
  type = string
}

variable "project" {
  type = string
}

variable "os_details_owner" {
  type = string
}


variable "instance_type" {
  type = string
}
variable "ec2_count" {
  type = number
  default = 1
}
variable "disk_size" {
  type = number
  default = 150
}

variable "subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "security_group" {
  type = list(string)
}

variable "tags" {
  type = map(any)
}