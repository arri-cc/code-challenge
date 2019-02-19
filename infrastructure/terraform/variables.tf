variable "fqdn" {
  type = "string"
}

variable "fqdn_app" {
  type = "string"
}

variable "fqdn_internal" {
  type = "string"
}

variable "suffix" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "aws_availability_zones" {
  type = "list"
}

variable "aws_elb_logs" {
  type = "map"
}

variable "vpc_network_cidr_block" {
  type    = "string"
  default = "10.10.220.0/24"
}

variable "vpc_network_subnet_cidr_blocks" {
  type = "list"

  default = [
    "10.10.220.0/26",
    "10.10.220.64/26",
    "10.10.220.128/26",
  ]
}

variable "replica_count" {
  type    = "string"
  default = "3"
}

variable "ec2_instance_type" {
  type = "string"
}

variable "ssh_public_key" {
  type = "string"
}

variable "asg_min" {
  type    = "string"
  default = "3"
}

variable "asg_max" {
  type    = "string"
  default = "6"
}

variable "asg_desired" {
  type    = "string"
  default = "3"
}

variable "asg_stack_name" {
  type = "string"
}
