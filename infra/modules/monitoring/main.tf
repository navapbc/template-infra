# Retrieve url for external incident management tool (e.g. Pagerduty, Splunk-On-Call)

data "aws_ssm_parameter" "this" {
  name = "Incident-management-integration-url-${var.app_name}-${var.environment}"
}

# Create SNS topic for all email and external incident management tools notifications

resource "aws_sns_topic" "this" {
  name = "${var.service_name}-monitoring"

  # checkov:skip=CKV_AWS_26:SNS encryption for alerts is unnecessary 
}

# Create CloudWatch alarms for the service

resource "aws_cloudwatch_metric_alarm" "high_app_http_5xx_count" {
  alarm_name                = "${var.service_name}-high-app-5xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 5
  metric_name               = "HTTPCode_Target_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "High HTTP service 5XX error count"
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_load_balancer_http_5xx_count" {
  alarm_name                = "${var.service_name}-high-load-balancer-5xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 5
  metric_name               = "HTTPCode_ELB_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "High HTTP ELB 5XX error count"
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_app_response_time" {
  alarm_name                = "${var.service_name}-high-app-response-time"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 5
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 0.2
  alarm_description         = "High target latency alert"
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
  }
}

#email integration

resource "aws_sns_topic_subscription" "email_integration" {
  for_each  = var.email_alerts
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}

#External incident management service integration
resource "aws_sns_topic_subscription" "ext_incident_management_tool" {
  count = data.aws_ssm_parameter.this.value != "" ? 1 : 0

  endpoint               = data.aws_ssm_parameter.this.value
  endpoint_auto_confirms = true
  protocol               = "https"
  topic_arn              = aws_sns_topic.this.arn
}

>>>>>>> feat: sns integrations
