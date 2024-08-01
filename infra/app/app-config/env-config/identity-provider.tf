# Identity provider configuration.
# If the notification service is configured, the identity provider will use the
# SES-verified email to send notifications.
locals {
  # If your application should redirect users, after successful authentication, to a
  # page other than the homepage, specify the path fragment here.
  # Example: "profile"
  callback_url_path = ""

  # If your application should redirect users, after signing out, to a page other than
  # the homepage, specify the path fragment here.
  # Example: "logout"
  logout_url_path = ""

  identity_provider_config = var.enable_identity_provider ? {
    identity_provider_name = "${local.prefix}${var.app_name}-${var.environment}"

    password_policy = {
      password_minimum_length          = 12
      temporary_password_validity_days = 7
    }

    # Optionally configure email template for resetting a password.
    # Set any attribute to a non-null value to override AWS Cognito defaults.
    verification_email = {
      verification_email_message = null
      verification_email_subject = null
    }

    # Do not modify this block directly.
    client = {
      callback_urls = concat(
        var.domain_name != null ? ["https://${var.domain_name}/${local.callback_url_path}"] : [],
        var.extra_identity_provider_callback_urls
      )
      logout_urls = concat(
        var.domain_name != null ? ["https://${var.domain_name}/${local.logout_url_path}"] : [],
        var.extra_identity_provider_logout_urls
      )
    }
  } : null
}
