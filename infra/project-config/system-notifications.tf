locals {
  
  # Configuration for system notifications
  # used by CI/CD workflows to send notifications for deployments,
  # failed workflows, etc.
  system_notifications_config = {

    # channels is a map of notification channels, where each key is a
    # notification channel and each value is the channel configuration.
    #
    # A channel configuration contains contains the following attributes:
    #   type: Type of notification channel (e.g. "slack", or "teams").
    #         currently only "slack" is supported
    #
    # If the channel `type` is missing or null, system notifications sent to
    # that channel will result in a no-op.
    #
    # If the channel `type` is "slack", the configuration must also contain the
    # following attributes:
    #   channel_id_secret_name: Name of the secret in GitHub that contains the
    #                           Slack channel ID
    #   slack_token_secret_name: Name of the secret in GitHub that contains the
    #                           Slack bot token
    channels = {
      workflow-failures = {
        # Uncomment if you want to send workflow failure notifications to Slack
        # "type" = "slack"
        # "channel_id_secret_name"  = "SYSTEM_NOTIFICATIONS_SLACK_CHANNEL_ID"
        # "slack_token_secret_name" = "SYSTEM_NOTIFICATIONS_SLACK_BOT_TOKEN"
      }
    }
  }
}
