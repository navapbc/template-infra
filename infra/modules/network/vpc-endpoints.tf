locals {
  # List of AWS services used by this VPC
  # This list is used to create VPC endpoints so that the AWS services can
  # be accessed without network traffic ever leaving the VPC's private network
  # For a list of AWS services that integrate with AWS PrivateLink
  # see https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html
  #
  # The database module requires VPC access from private networks to SSM, KMS, and RDS
  aws_service_integrations = setunion(
    # AWS services used by ECS Fargate: ECR to fetch images, S3 for image layers, and CloudWatch for logs
    ["ecr.api", "ecr.dkr", "s3", "logs"],

    # Workaround: Feature flags use AWS Evidently, but we are going to create that VPC endpoint separately
    # rather than as part of this list in order to get around the limitation that AWS Evidently
    # is not available in some availability zones (at the time of writing)

    # AWS services used by the database's role manager
    var.has_database ? ["ssm", "kms", "secretsmanager"] : [],
  )

  # S3 and DynamoDB use Gateway VPC endpoints. All other services use Interface VPC endpoints
  interface_vpc_endpoints = toset([for aws_service in local.aws_service_integrations : aws_service if !contains(["s3", "dynamodb"], aws_service)])
  gateway_vpc_endpoints   = toset([for aws_service in local.aws_service_integrations : aws_service if contains(["s3", "dynamodb"], aws_service)])
}

data "aws_region" "current" {}

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

resource "aws_security_group" "aws_services" {
  name_prefix = var.aws_services_security_group_name_prefix
  description = "VPC endpoints to access AWS services from the VPCs private subnets"
  vpc_id      = module.aws_vpc.vpc_id
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_vpc_endpoints

  vpc_id              = module.aws_vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.aws_services.id]
  subnet_ids          = module.aws_vpc.private_subnets
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = local.gateway_vpc_endpoints

  vpc_id            = module.aws_vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.aws_vpc.private_route_table_ids
}

# Interface VPC Endpoint for AWS CloudWatch Evidently (Workaround)
# ----------------------------------------------------------------
#
# Add Interface VPC Endpoint for AWS CloudWatch Evidently separately from other VPC Endpoints,
# because at the time of writing, Evidently isn't supported in certain availability zones.
# So we filter down the list of private subnets by the ones in the availability zones that are
# supported by Evidently before creating the VPC endpoint.

data "aws_subnet" "private" {
  count = length(module.aws_vpc.private_subnets)
  id    = module.aws_vpc.private_subnets[count.index]
}

locals {
  # At the time of writing, these are the only availability zones supported by AWS CloudWatch Evidently
  # This list was obtained by using the AWS Console, going through each US region, attempting to add
  # a VPC endpoint for Evidently in the default VPC, and seeing which availability zones show up as
  # options.
  evidently_az_ids = [
    "use1-az2",
    "use1-az4",
    "use1-az6",
    "use2-az1",
    "use2-az2",
    "use2-az3",
    "usw2-az1",
    "usw2-az2",
    "usw2-az3",
  ]

  evidently_dataplane_az_ids = [
    "use1-az1",
    "use1-az4",
    "use1-az6",
    "use2-az1",
    "use2-az2",
    "use2-az3",
    "usw2-az1",
    "usw2-az2",
    "usw2-az3",
  ]

  aws_evidently_subnet_ids = [
    for subnet in data.aws_subnet.private[*] : subnet.id
    if contains(local.evidently_az_ids, subnet.availability_zone_id)
  ]

  aws_evidently_dataplane_subnet_ids = [
    for subnet in data.aws_subnet.private[*] : subnet.id
    if contains(local.evidently_dataplane_az_ids, subnet.availability_zone_id)
  ]
}

resource "aws_vpc_endpoint" "evidently" {
  vpc_id              = module.aws_vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.evidently"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.aws_services.id]
  subnet_ids          = local.aws_evidently_subnet_ids
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "evidently_dataplane" {
  vpc_id              = module.aws_vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.evidently-dataplane"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.aws_services.id]
  subnet_ids          = local.aws_evidently_dataplane_subnet_ids
  private_dns_enabled = true
}
