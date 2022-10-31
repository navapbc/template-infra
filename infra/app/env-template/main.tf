# ECS cluster for running applications in an environment.
#
# Applications within this cluster are not actually tied
# to a VPC/environment, but we separate them to improve
# organization and simplify lookups.
module "cluster" {
  source = "../../modules/cluster"
  name   = var.environment_name
}
