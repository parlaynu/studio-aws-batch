## project id

variable "project_name" {
  type = string
}

data "external" "user" {
  program = ["scripts/current-user.sh"]
}

locals {
  user = data.external.user.result["user"]
}

## Network

variable "gateway_cidr_block" {
  type = string
  default = "172.16.4.0/22"
}

variable "private_cidr_block" {
  type = string
  default = "172.16.16.0/20"
}

variable "num_zones" {
  type = number
  default = 1
  description = "the number of zones to build in - overridden by var.zones"
}

variable "zones" {
  type = list(string)
  default = []
  description = "manually specify what zones to use - overrides var.num_zones"
}

locals {
  # the max number we can have, regardless of what is configured in 'var.num_zones' or 'var.zones'
  max_zones = min(length(data.aws_availability_zones.available.names), 4)
  
  # the number of zones
  num_zones = max(1, min(length(var.zones) > 0 ? length(var.zones) : var.num_zones, local.max_zones))

  # the zones
  zones = slice(length(var.zones) > 0 ? var.zones : reverse(data.aws_availability_zones.available.names), 0, local.num_zones)

  zone_ids = { for zone in local.zones : zone => join("-", [var.project_name, split("-", zone)[2]]) }
  
  gateway_cidr_blocks = { for i, zone in local.zones : zone => cidrsubnet(var.gateway_cidr_block, 2, i) }
  private_cidr_blocks = { for i, zone in local.zones : zone => cidrsubnet(var.private_cidr_block, 2, i) }
}

data "aws_availability_zones" "available" {
  state = "available"
}

## Network Features

variable "enable_gateways" {
  type = bool
  default = true
}

variable "enable_endpoints" {
  type = bool
  default = false
}

locals {
  endpoint_count = var.enable_endpoints ? 1 : 0
}

## Buckets

variable "ro_buckets" {
  type = list(string)
  default = []
}

variable "rw_buckets" {
  type = list(string)
  default = []
}

## Management IP

data "external" "management_ip" {
  program = ["scripts/management-ip.sh"]
}

locals {
  management_ip  = data.external.management_ip.result["my_public_ip"]
}


## AWS settings

variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_instance_type" {
  type = string
  default = "t3.micro"
}

locals {
    aws_account_id = data.aws_caller_identity.current.account_id
    aws_ami_id = var.aws_ami_id == "" ? data.aws_ami.gateway.id : var.aws_ami_id
}

data "aws_caller_identity" "current" {}

variable "aws_ami_id" {
  type = string
  default = ""
}

variable "aws_ami_owner" {
  default = "099720109477"
  description = "canonical in ap-southeast-2"
}

data "aws_ami" "gateway" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.aws_ami_owner]
}

