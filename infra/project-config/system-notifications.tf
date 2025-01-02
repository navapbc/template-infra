locals {
  topics = {
    "workflows" = {
    }
  }

  system_notifications_config = {
    channels = {
      workflow-failures = {
        # Uncomment if you want to send notifications to a Slack channel
        # "type" = "slack"
        # # Name of the secret in GitHub
        # "channel_id_secret_name"  = "SYSTEM_NOTIFICATIONS_SLACK_CHANNEL_ID"
        # "slack_token_secret_name" = "SYSTEM_NOTIFICATIONS_SLACK_BOT_TOKEN"
      }
    }
  }
}
