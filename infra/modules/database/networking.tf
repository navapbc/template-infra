# Network Configuration
# ---------------------

resource "aws_security_group" "db" {
  name_prefix = "${var.name}-db"
  description = "Database layer security group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "role_manager" {
  name_prefix = "${var.name}-role-manager"
  description = "Database role manager security group"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "role_manager_egress_to_db" {
  security_group_id = aws_security_group.role_manager.id
  description       = "Allow role manager to access database"

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.db.id
}

resource "aws_vpc_security_group_ingress_rule" "db_ingress_from_role_manager" {
  security_group_id = aws_security_group.db.id
  description       = "Allow inbound requests to database from role manager"

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.role_manager.id
}

# VPC Endpoints for accessing AWS Services
# ----------------------------------------
#
# Since the role manager Lambda function is in the VPC (which is needed to be
# able to access the database) we need to allow the Lambda function to access
# AWS Systems Manager Parameter Store (to fetch the database password) and
# KMS (to decrypt SecureString parameters from Parameter Store). We can do
# this by either allowing internet access to the Lambda, or by using a VPC
# endpoint. The latter is more secure.
# See https://repost.aws/knowledge-center/lambda-vpc-parameter-store
# See https://docs.aws.amazon.com/vpc/latest/privatelink/create-interface-endpoint.html#create-interface-endpoint

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = var.private_subnet_ids
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.kms"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = var.private_subnet_ids
  private_dns_enabled = true
}

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.name}-vpc-endpoints"
  description = "VPC endpoints to access SSM and KMS"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "role_manager_egress_to_vpc_endpoints" {
  security_group_id = aws_security_group.role_manager.id
  description       = "Allow outbound requests from role manager to VPC endpoints"

  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.vpc_endpoints.id
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_ingress_from_role_manager" {
  security_group_id = aws_security_group.vpc_endpoints.id
  description       = "Allow inbound requests to VPC endpoints from role manager"

  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.role_manager.id
}
