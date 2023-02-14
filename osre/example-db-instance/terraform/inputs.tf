data "terraform_remote_state" "common" {
  backend   = "s3"
  workspace = "common"

  config = {
    bucket = var.tf_state_bucket
    key    = "${var.environment_name}/state.tfstate"
    region = var.aws_region
  }
}

module "gdit_vpc_data" {
  source   = "../../../modules/network-v3-0.12/terraform"
  vpc_name = var.vpc_name
  vpc_type = var.vpc_type
}