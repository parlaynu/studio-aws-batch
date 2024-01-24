## 
## NOTE: when working at scale, the endpoints are needed so can support 
##       downloading from a lot of nodes. When testing with just one or
##       two nodes, the gateway instance is good enough and avoids the
##       costs of endpoints.
##

resource "aws_vpc_endpoint" "s3" {
  count             = local.endpoint_count
  vpc_id            = aws_vpc.network.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  tags = {
    Name = "${var.project_name}-s3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  for_each = { for k, v in local.gateway_cidr_blocks: k => v if var.enable_endpoints }
  route_table_id  = aws_route_table.private[each.key].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = local.endpoint_count
  vpc_id              = aws_vpc.network.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [ for item in aws_subnet.private: item.id ]
  security_group_ids  = [ aws_security_group.private.id ]
  tags = {
    Name = "${var.project_name}-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  count               = local.endpoint_count
  vpc_id              = aws_vpc.network.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [ for item in aws_subnet.private: item.id ]
  security_group_ids  = [ aws_security_group.private.id ]
  tags = {
    Name = "${var.project_name}-ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecs" {
  count               = local.endpoint_count
  vpc_id              = aws_vpc.network.id
  service_name        = "com.amazonaws.${var.aws_region}.ecs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [ for item in aws_subnet.private: item.id ]
  security_group_ids  = [ aws_security_group.private.id ]
  tags = {
    Name = "${var.project_name}-ecs"
  }
}

resource "aws_vpc_endpoint" "ecs_agent" {
  count               = local.endpoint_count
  vpc_id              = aws_vpc.network.id
  service_name        = "com.amazonaws.${var.aws_region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [ for item in aws_subnet.private: item.id ]
  security_group_ids  = [ aws_security_group.private.id ]
  tags = {
    Name = "${var.project_name}-ecs-agent"
  }
}

resource "aws_vpc_endpoint" "ecs_telemetry" {
  count               = local.endpoint_count
  vpc_id              = aws_vpc.network.id
  service_name        = "com.amazonaws.${var.aws_region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [ for item in aws_subnet.private: item.id ]
  security_group_ids  = [ aws_security_group.private.id ]
  tags = {
    Name = "${var.project_name}-ecs-telemetry"
  }
}

resource "aws_vpc_endpoint" "logs" {
  count               = local.endpoint_count
  vpc_id              = aws_vpc.network.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [ for item in aws_subnet.private: item.id ]
  security_group_ids  = [ aws_security_group.private.id ]
  tags = {
    Name = "${var.project_name}-logs"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  count               = local.endpoint_count
  vpc_id              = aws_vpc.network.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [ for item in aws_subnet.private: item.id ]
  security_group_ids  = [ aws_security_group.private.id ]
  tags = {
    Name = "${var.project_name}-ssm"
  }
}

