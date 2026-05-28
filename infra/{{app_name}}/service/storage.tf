locals {
  storage_config = local.environment_config.storage_config
  bucket_name    = "${local.prefix}${local.storage_config.bucket_name}"
}

module "storage" {
  source                  = "../../modules/storage"
  name                    = local.bucket_name
  is_temporary            = local.is_temporary
  enable_malware_scanning = module.app_config.enable_storage_malware_scanning
}
