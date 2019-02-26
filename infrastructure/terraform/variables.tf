variable "fqdn" {
  description = "FQDN for the DNS Zone in Route53"
  type        = "string"
}

variable "fqdn_app" {
  description = "FQDN for the app, for this project it's a subdomain in the DNS Zone"
  type        = "string"
}

variable "fqdn_cdn" {
  description = "FQDN for the custom CDN URL"
  type        = "string"
}

variable "fqdn_internal" {
  description = "FQDN for private DNS within the VPC"
  type        = "string"
}

variable "suffix" {
  description = "metadata to tag resources"
  type        = "string"
}

variable "aws_region" {
  description = "default region for most operations"
  type        = "string"
}

variable "aws_s3_bucket_for_cdn" {
  description = "name of the s3 bucket used for CDN distributions"
  type        = "string"
}

variable aws_s3_bucket_for_cdn_acl {
  description = "The ACL for the s3 bucket used for CDN distribution"
  type        = "string"
}

variable aws_s3_bucket_for_cdn_content_acl {
  description = "The ACL for the s3 objects within the s3 bucket for CDN distribution"
  type        = "string"
}

variable "content_for_cdn" {
  description = "Content for distribution via CDN"
  type        = "map"

  default = {
    "/images/rickroll.gif" = "../../src/LuckyApp/LuckyApp/wwwroot/images/rickroll.gif"
  }
}

variable "logs_cdn" {
  description = "prefix for cdn logs"
  type        = "string"
  default     = "cloudfrontlogs"
}

variable "aws_availability_zones" {
  description = "List of target availability zones"
  type        = "list"
}

variable "aws_elb_logs" {
  description = "ELB log configuration"
  type        = "map"
}

variable "vpc_network_cidr_block" {
  description = "Defines the entire IP Address block for the VPC"
  type        = "string"
  default     = "10.10.220.0/24"
}

variable "replica_count" {
  description = "number of instances, used for other resources like subnets"
  type        = "string"
}

variable "vpc_network_subnet_cidr_blocks" {
  description = "Defines the IP Address blocks for each subnet"
  type        = "list"

  default = [
    "10.10.220.0/26",
    "10.10.220.64/26",
    "10.10.220.128/26",
  ]
}

variable "ec2_instance_type" {
  description = "The desired EC2 instance type"
  type        = "string"
}

variable "ssh_public_key" {
  description = "The SSH public key to authenticate against each EC2 instance"
  type        = "string"
}

variable "asg_min" {
  description = "The minimum number of EC2 instances in the Auto-Scaling Group"
  type        = "string"
  default     = "3"
}

variable "asg_max" {
  description = "The maximum number of EC2 instances in the Auto-Scaling Group"
  type        = "string"
  default     = "6"
}

variable "asg_desired" {
  description = "The desired number of EC2 instances in the Auto-Scaling Group"
  type        = "string"
  default     = "3"
}

variable "asg_stack_name" {
  description = "The unique name for the Auto-Scaling Group CloudFormation stack"
  type        = "string"
}
