module "service" {
  source = "../../modules/app-service"
  name   = var.environment_name
}
