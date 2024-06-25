# Identity provider configuration
locals {
  enable_identity_provider = var.enable_identity_provider

  identity_provider_config = var.enable_identity_provider ? {
    identity_provider_name   = "${local.prefix}${var.app_name}-${var.environment}"

    password_policy = {
      password_minimum_length          = 12
      temporary_password_validity_days = 7
    }

    client = {
      # Support local development against remote resources
      auth_callback_urls = concat(
        var.domain_name != null ? ["https://${var.domain_name}"] : [],
        var.extra_identity_provider_callback_urls
      )
      logout_urls = concat(
        var.domain_name != null ? ["https://${var.domain_name}"] : [],
        var.extra_identity_provider_logout_urls
      )
    }

    # Set any values not `null` to override AWS Cognito defaults.
    email = {
      # When you're ready to use SES instead of the Cognito default to send emails, set this
      # to the SES-verified email address to be used when sending emails.
      sender_email = null

      # Configure the name that users see in the "From" section of their inbox, so that it's
      # clearer who the email is from.
      sender_display_name = null

      # Configure the REPLY-TO email address if it should be different from the sender.
      reply_to_email = null
    }

    # Optionally configure email template for resetting a password.
    # Set any values not `null` to override AWS Cognito defaults.
    verification_email = {
      verification_email_message = null
      verification_email_subject = null
    }
  } : null
}
