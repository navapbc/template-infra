# Notifications configuration
locals {
  notifications_config = var.enable_notifications && var.domain_name != null && local.network_config.domain_config.hosted_zone != null ? {
    # Notification configuration name.
    name = "${var.app_name}-${var.environment}"

    # Configure the name that users see in the "From" section of their inbox,
    # so that it's clearer who the email is from.
    sender_display_name = null

    # Set to the email address to be used when sending emails.
    # If enable_notifications is true, this is required.
    sender_email = "notifications@${var.domain_name}"

    # Configure the REPLY-TO email address if it should be different from the sender.
    reply_to_email = "notifications@${var.domain_name}"
  } : null
  sms_config = var.enable_sms_notifications ? {
    # SMS configuration name.
    name = "${var.app_name}-${var.environment}-sms"

    # Type of SMS number to use: "LONG_CODE", "TOLL_FREE". For more information,
    # see https://docs.aws.amazon.com/sms-voice/latest/userguide/phone-number-types.html.
    sms_number_type = var.sms_number_type

    # The AWS End User Messaging Service (EUMS) registration ID to use to provision the sender phone number.
    # This is the registration ID provided by AWS when registering the phone number.
    sms_sender_phone_number_registration_id = var.sms_sender_phone_number_registration_id

  } : null
}
