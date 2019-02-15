variable "fqdn" {
  type    = "string"
  default = "luckyday.arri.io"
}

variable "fqdn_app" {
  type    = "string"
  default = "app2.luckyday.arri.io"
}

variable "fqdn_internal" {
  type    = "string"
  default = "luckyday.arri.internal"
}

variable "suffix" {
  type    = "string"
  default = "-luckyday-arri-io"
}

variable "aws_region" {
  type    = "string"
  default = "us-west-2"
}

variable "aws_availability_zones" {
  type = "list"

  default = [
    "us-west-2a",
    "us-west-2b",
    "us-west-2c",
  ]
}

variable "aws_elb_logs" {
  type = "map"

  default = {
    bucket = "luckyday-arri-storage"
    path   = "elb/logs"
  }
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
  type    = "string"
  default = "t3.nano"
}

variable "ssh_public_key" {
  type    = "string"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLlBfnNTlOU23fcbzxUOMQAWEw4jRx5fGrOLcVEdyby+o9UBDzC4KIQNNhqDvL2Hw7m+osvYuACxp7+nqNhqF5iljOo5UqbcqVjwaWOayBBh3Ehg/4B3LAIeLP44dTML7wH2xPvhY+KjpFiIjM3UARlya30N645zSvn6HsxthRNzViF6JXSuUaxc+Sjmg4+KfM5MYrwRVDtYp1IYXi1TlMDAu2NWwKFG8D8/X7XlIsnNsIx6ZlMgKmOxvrUci+QXkD3OJSMxZ8cubQmajE4ErI+CJ/7+rFbPPFodmWl6vcHAQHytQMGa1Nj7gjJgdlVZWH4bS+hLuRIBlnEUjRfEMF luckyday"
}

variable "s3_cdn_image_name" {
  type    = "string"
  default = "rick-astely.gif"
}

variable "s3_cdn_image_path" {
  type    = "string"
  default = "../../src/LuckyApp/LuckyApp/wwwroot/images/rick-astley.gif"
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
  type    = "string"
  default = "my-luckyday-asg"
}
