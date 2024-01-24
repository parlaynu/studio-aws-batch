
## gateway and private server

locals {
  gateway_servers = { for key, server in aws_instance.gateway :
    local.zone_ids[key] => {
      "public_ip" = server.public_ip
      "private_ip" = server.private_ip
      "zone" = server.availability_zone
    }
  }
}

## the vpc

resource "aws_vpc" "network" {
  cidr_block = var.gateway_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = var.enable_endpoints
  tags = {
    Name = var.project_name
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "private_cidr_block" {
  vpc_id     = aws_vpc.network.id
  cidr_block = var.private_cidr_block
}

resource "aws_default_route_table" "network" {
  default_route_table_id = aws_vpc.network.default_route_table_id
  tags = {
    Name = "${var.project_name}-default"
  }
}

resource "aws_default_security_group" "network" {
  vpc_id = aws_vpc.network.id
  tags = {
    Name = "${var.project_name}-default"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.network.id
  tags = {
    Name = "${var.project_name}-gw"
  }
}

## gateway subnets

resource "aws_subnet" "gateway" {
  for_each = local.gateway_cidr_blocks
  
  vpc_id            = aws_vpc.network.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "${local.zone_ids[each.key]}-gw"
  }
}

resource "aws_route_table_association" "gateway" {
  for_each = local.gateway_cidr_blocks
  subnet_id      = aws_subnet.gateway[each.key].id
  route_table_id = aws_route_table.gateway.id
}

resource "aws_route_table" "gateway" {
  vpc_id = aws_vpc.network.id
  tags = {
    Name = "${var.project_name}-gw"
  }
}

resource "aws_route" "gateway_default" {
  route_table_id         = aws_route_table.gateway.id
  gateway_id             = aws_internet_gateway.gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "gateway" {
  for_each = local.gateway_cidr_blocks
  vpc_id = aws_vpc.network.id
  tags = {
    Name = "${local.zone_ids[each.key]}-gw"
  }
}

resource "aws_security_group_rule" "gateway_egress" {
  for_each = local.gateway_cidr_blocks
  security_group_id = aws_security_group.gateway[each.key].id
  type        = "egress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "gateway_self" {
  for_each = local.gateway_cidr_blocks
  security_group_id = aws_security_group.gateway[each.key].id
  type        = "ingress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  self        = true
}

resource "aws_security_group_rule" "gateway_private" {
  for_each = local.gateway_cidr_blocks
  security_group_id = aws_security_group.gateway[each.key].id
  type        = "ingress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  source_security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "gateway_ssh" {
  for_each = local.gateway_cidr_blocks
  security_group_id = aws_security_group.gateway[each.key].id
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = [ "${local.management_ip}/32" ]
}


## private subnets

resource "aws_subnet" "private" {
  for_each = local.private_cidr_blocks
  vpc_id            = aws_vpc.network.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = {
    Name = "${local.zone_ids[each.key]}-pvt"
  }
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.private_cidr_block
  ]
}

resource "aws_route_table_association" "private" {
  for_each = local.private_cidr_blocks
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table" "private" {
  for_each = local.private_cidr_blocks
  vpc_id = aws_vpc.network.id
  tags = {
    Name = "${local.zone_ids[each.key]}-pvt"
  }
}

resource "aws_route" "private_default" {
  for_each = aws_instance.gateway
  route_table_id         = aws_route_table.private[each.key].id
  network_interface_id   = aws_instance.gateway[each.key].primary_network_interface_id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "private" {
  vpc_id = aws_vpc.network.id
  tags = {
    Name = "${var.project_name}-pvt"
  }
}

resource "aws_security_group_rule" "private_egress" {
  security_group_id = aws_security_group.private.id
  type        = "egress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "private_self" {
  security_group_id = aws_security_group.private.id
  type        = "ingress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  self        = true
}

resource "aws_security_group_rule" "private_gateway" {
  for_each = local.gateway_cidr_blocks
  security_group_id = aws_security_group.private.id
  type        = "ingress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  source_security_group_id = aws_security_group.gateway[each.key].id
}

## add instance to gateway subnets


resource "aws_instance" "gateway" {
  for_each = { for zone, block in local.gateway_cidr_blocks: zone => block if var.enable_gateways }

  instance_type = var.aws_instance_type
  ami           = local.aws_ami_id

  disable_api_termination     = false
  associate_public_ip_address = true
  source_dest_check           = false

  subnet_id                   = aws_subnet.gateway[each.key].id
  private_ip                  = cidrhost(local.gateway_cidr_blocks[each.key], 6)
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.gateway[each.key].id]

  tags = {
    Name = "${local.zone_ids[each.key]}-gw"
  }

  user_data = <<-EOF
  #!/usr/bin/env bash
  hostnamectl set-hostname ${local.zone_ids[each.key]}
  EOF
}

