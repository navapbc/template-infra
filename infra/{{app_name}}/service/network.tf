locals {
  network_config = module.project_config.network_configs[local.environment_config.network_name]
}

data "aws_vpc" "network" {
  tags = {
    project      = module.project_config.project_name
    network_name = local.environment_config.network_name
  }
}

data "aws_subnets" "public" {
  tags = {
    project      = module.project_config.project_name
    network_name = local.environment_config.network_name
    subnet_type  = "public"
  }
}

data "aws_subnets" "private" {
  tags = {
    project      = module.project_config.project_name
    network_name = local.environment_config.network_name
    subnet_type  = "private"
  }
}

data "aws_security_groups" "aws_services" {
  filter {
    name   = "group-name"
    values = ["${module.project_config.aws_services_security_group_name_prefix}*"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.network.id]
  }
}
