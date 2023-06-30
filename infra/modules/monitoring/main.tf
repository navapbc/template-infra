# Create SNS topic for all email and external incident management tools notifications

resource "aws_sns_topic" "this" {
  name = "${var.service_name}-monitoring-notifications"

  # checkov:skip=CKV_AWS_26:SNS encryption for alerts is unnecessary 
}

# Create CloudWatch alarms for the service

resource "aws_cloudwatch_metric_alarm" "high_http_target_5xx_error_count_threshold" {
  count                     = var.high_http_target_5xx_error_count_threshold != null ? 1 : 0
  alarm_name                = "${var.service_name}-high-http-target-5xx-error-count-threshold"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 5
  metric_name               = "HTTPCode_Target_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = var.high_http_target_5xx_error_count_threshold
  alarm_description         = "High HTTP service 5XX error count"
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_http_elb_5xx_error_count_threshold" {
  count                     = var.high_http_elb_5xx_error_count_threshold != null ? 1 : 0
  alarm_name                = "${var.service_name}-high-http-elb-5xx-error-count-threshold"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 5
  metric_name               = "HTTPCode_ELB_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = var.high_http_elb_5xx_error_count_threshold
  alarm_description         = "High HTTP ELB 5XX error count"
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_target_response_time_threshold" {
  count                     = var.high_target_response_time_threshold != null ? 1 : 0
  alarm_name                = "${var.service_name}-high_target_response_time_threshold"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 5
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Average"
  threshold                 = var.high_target_response_time_threshold
  alarm_description         = "High target latency alert"
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
  }
}
