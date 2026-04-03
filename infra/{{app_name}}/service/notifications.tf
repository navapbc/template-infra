data "aws_region" "current" {}

locals {
  notifications_config = local.environment_config.notifications_config
  sms_config           = local.environment_config.sms_config

  # If this is a temporary environment, re-use an existing email identity. Otherwise, create a new one.
  domain_identity_arn = local.notifications_config != null ? (
    !local.is_temporary ?
    module.notifications_email_domain[0].domain_identity_arn :
    module.existing_notifications_email_domain[0].domain_identity_arn
  ) : null
  notifications_environment_variables = local.notifications_config != null ? {
    AWS_SES_FROM_EMAIL = module.notifications[0].from_email
  } : {}
  notifications_app_name = local.notifications_config != null ? "${local.prefix}${local.notifications_config.name}" : ""

  # Phone pool logic:
  # - Permanent environments: always create new
  # - Temporary environments: reuse existing if found in current region, otherwise create new

  # Get pool from current region (for temporary environments)
  current_region_pool = local.sms_config != null && local.is_temporary ? try(
    module.existing_notifications_phone_pool[0].pools_by_region[data.aws_region.current.name],
    null
  ) : null

  # Check if existing pool exists in current region
  has_existing_pool = local.current_region_pool != null ? try(local.current_region_pool.exists, false) : false

  phone_pool_arn = local.sms_config != null ? (
    !local.is_temporary ?
    module.notifications_phone_pool[0].phone_pool_arn :
    (local.has_existing_pool ?
      local.current_region_pool.pool_arn :
    module.notifications_phone_pool_temp[0].phone_pool_arn)
  ) : null

  phone_pool_id = local.sms_config != null ? (
    !local.is_temporary ?
    module.notifications_phone_pool[0].phone_pool_id :
    (local.has_existing_pool ?
      local.current_region_pool.pool_id :
    module.notifications_phone_pool_temp[0].phone_pool_id)
  ) : null

  # SMS environment variables for notifications-sms module
  sms_environment_variables = local.sms_config != null ? {
    AWS_SMS_CONFIGURATION_SET_NAME = module.notifications_sms[0].configuration_set_name
    AWS_SMS_PHONE_POOL_ARN         = local.phone_pool_arn
    AWS_SMS_PHONE_POOL_ID          = local.phone_pool_id
  } : {}
  sms_app_name = local.sms_config != null ? "${local.prefix}${local.sms_config.name}" : ""
}

# If the app has `enable_sms_notifications` set to true AND this is not a temporary
# environment, then create SMS phone pool resources.
module "notifications_phone_pool" {
  count  = local.sms_config != null && !local.is_temporary ? 1 : 0
  source = "../../modules/notifications-phone-pool/resources"

  name                                    = local.sms_app_name
  sms_sender_phone_number_registration_id = local.sms_config.sms_sender_phone_number_registration_id
  sms_number_type                         = local.sms_config.sms_number_type
}

# If the app has `enable_sms_notifications` set to true AND this *is* a temporary
# environment, then find existing phone pool resources.
module "existing_notifications_phone_pool" {
  count  = local.sms_config != null && local.is_temporary ? 1 : 0
  source = "../../modules/notifications-phone-pool/data"
}

# If the app has `enable_sms_notifications` set to true AND this is a temporary
# environment AND no existing phone pool was found, then create SMS phone pool resources.
module "notifications_phone_pool_temp" {
  count  = local.sms_config != null && local.is_temporary && !local.has_existing_pool ? 1 : 0
  source = "../../modules/notifications-phone-pool/resources"

  name                                    = local.sms_app_name
  sms_sender_phone_number_registration_id = local.sms_config.sms_sender_phone_number_registration_id
  sms_number_type                         = local.sms_config.sms_number_type
}

# If the app has `enable_sms_notifications` set to true, create SMS configuration set and IAM policies.
# A new configuration set and policy are created for all environments, including temporary environments.
module "notifications_sms" {
  count  = local.sms_config != null ? 1 : 0
  source = "../../modules/notifications-sms/resources"

  name           = local.sms_app_name
  phone_pool_arn = local.phone_pool_arn
}

# If the app has `enable_notifications` set to true AND this is not a temporary
# environment, then create a email notification identity.
module "notifications_email_domain" {
  count  = local.notifications_config != null && !local.is_temporary ? 1 : 0
  source = "../../modules/notifications-email-domain/resources"

  domain_name    = module.domain.domain_name
  hosted_zone_id = module.domain.hosted_zone_id
}

# If the app has `enable_notifications` set to true AND this *is* a temporary
# environment, then create a email notification identity.
module "existing_notifications_email_domain" {
  count  = local.notifications_config != null && local.is_temporary ? 1 : 0
  source = "../../modules/notifications-email-domain/data"

  domain_name = module.domain.domain_name
}

# If the app has `enable_notifications` set to true, create IAM policies for SES access.
# A new policy is created for all environments, including temporary environments.
module "notifications" {
  count  = local.notifications_config != null ? 1 : 0
  source = "../../modules/notifications/resources"

  name                = local.notifications_app_name
  domain_identity_arn = local.domain_identity_arn
  sender_display_name = local.notifications_config.sender_display_name
  sender_email        = local.notifications_config.sender_email
}
