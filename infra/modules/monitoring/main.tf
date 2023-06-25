# Create CloudWatch alarms for ECS metrics

resource "aws_cloudwatch_metric_alarm" "cpu" {
  count                     = var.cpu_threshold != "" ? 1 : 0
  alarm_name                = "${var.ecs_name}-cpu-usage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 120
  statistic                 = "Average"
  threshold                 = var.cpu_threshold
  alarm_description         = "This metric monitors ecs cluster cpu utilization"
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]
  #treat_missing_data        = "breaching"

  dimensions = {
    ClusterName = var.ecs_name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm" {
  alarm_name                = "${var.ecs_name}-memory-utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 3
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = 300
  statistic                 = "Average"
  threshold                 = var.memory_util_threshold
  alarm_description         = "Alarm triggered when memory utilization is above 70% for 15 minutes."
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]
  dimensions = {
    ClusterName = var.ecs_name
  }
}

resource "aws_cloudwatch_metric_alarm" "task_health_alarm" {
  alarm_name                = "${var.ecs_name}-task-health"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  metric_name               = "TaskHealthPercentage"
  namespace                 = "AWS/ECS"
  period                    = 60
  statistic                 = "Minimum"
  threshold                 = var.task_health_threshold
  alarm_description         = "Alarm triggered when any ECS task becomes unhealthy."
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]
  dimensions = {
    ClusterName = var.ecs_name
  }
}

resource "aws_cloudwatch_metric_alarm" "task_placement_errors_alarm" {
  alarm_name                = "${var.ecs_name}-task-placement-errors"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 3
  metric_name               = "TaskPlacementError"
  namespace                 = "AWS/ECS"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = var.task_placement_threshold
  alarm_description         = "Alarm triggered when ECS tasks encounter placement errors."
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]
  dimensions = {
    ClusterName = var.ecs_name
  }
}

resource "aws_cloudwatch_metric_alarm" "service_availability_alarm" {
  alarm_name                = "${var.ecs_name}-service-availability"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  metric_name               = "ServiceAvailability"
  namespace                 = "AWS/ECS"
  period                    = 60
  statistic                 = "Minimum"
  threshold                 = var.service_availability_threshold
  alarm_description         = "Alarm triggered when an ECS service becomes unavailable."
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]
  dimensions = {
    ClusterName = var.ecs_name
  }
}

resource "aws_cloudwatch_metric_alarm" "network_connectivity_alarm" {
  alarm_name                = "${var.ecs_name}-network-connectivity"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  metric_name               = "NetworkPacketsLost"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = var.network_connectivity_threshold
  alarm_description         = "Alarm triggered when network connectivity issues are detected."
  alarm_actions             = [aws_sns_topic.this.arn]
  ok_actions                = [aws_sns_topic.this.arn]
  insufficient_data_actions = [aws_sns_topic.this.arn]
  dimensions = {
    ClusterName = var.ecs_name
  }
}

# Create SNS topic for all email and external incident management tools notifications

resource "aws_sns_topic" "this" {
  name = "${var.ecs_name}-monitoring-notifications"
}
