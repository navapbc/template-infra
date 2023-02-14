data "terraform_remote_state" "mtde_rds_aurora" {
  backend   = "s3"
  workspace = "example-db"

  config = {
    bucket = var.tf_state_bucket
    key    = "${var.environment_name}/state.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "common" {
  backend   = "s3"
  workspace = "common"

  config = {
    bucket = var.tf_state_bucket
    key    = "${var.environment_name}/state.tfstate"
    region = var.aws_region
  }
}
