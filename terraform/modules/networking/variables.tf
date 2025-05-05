# create critical resources
variable "create_igw" {
  type    = bool
  default = true
}
variable "create_nat_gw" {
  type    = bool
  default = true
}
variable "create_vpc" {
  type    = bool
  default = true
}
# required variables
variable "region" {
  type = string
}
variable "project" {
  type = string
}
variable "tags" {
  type = map(any)
}

# variables for vpc
variable "cidr_block" {
  type = string
}
variable "imported_vpc_id" {
  type    = string
  default = null
}
variable "imported_igw_id" {
  type    = string
  default = null
}

# variables for internet gateway
variable "public_cidr_block" {
  type = list(string)
}

variable "private_cidr_block" {
  type = list(string)
}

# variables for security groups
variable "cidr_block_sg_lb" {
  type = string
}

variable "cidr_block_sg_db" {
  type = string
}

variable "cidr_block_sg_microservice" {
  type = string
}
