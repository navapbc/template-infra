locals {
  prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
}
