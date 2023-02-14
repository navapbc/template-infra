// CloudWatch alarm if DB connections for writer >= 500
resource "aws_cloudwatch_metric_alarm" "writer_db_connections" {
  alarm_name          = "${aws_rds_cluster.rds_aurora_cluster.id}-writer-dbconnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "500"
  alarm_description   = "RDS Aurora cluster writer connections >= 500"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.rds_aurora_cluster.id
    Role                = "WRITER"
  }

  // Notifications actions
  alarm_actions = [var.cloudwatch_notification_arn]
  ok_actions    = [var.cloudwatch_notification_arn]

}

// CloudWatch alarm if DB connections for reader >= 500
resource "aws_cloudwatch_metric_alarm" "reader_db_connections" {
  alarm_name          = "${aws_rds_cluster.rds_aurora_cluster.id}-reader-dbconnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "500"
  alarm_description   = "RDS Aurora cluster reader connections >= 500"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.rds_aurora_cluster.id
    Role                = "READER"
  }

  // Notifications actions
  alarm_actions = [var.cloudwatch_notification_arn]
  ok_actions    = [var.cloudwatch_notification_arn]

}

resource "aws_cloudwatch_metric_alarm" "writer_cpu_utilization" {
  alarm_name          = "${aws_rds_cluster.rds_aurora_cluster.id}-writer-cpu_utilization"
  comparison_operator = var.writer_cpu_utilization.comparison_operator
  evaluation_periods  = var.writer_cpu_utilization.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.writer_cpu_utilization.period
  statistic           = var.writer_cpu_utilization.statistic
  threshold           = var.writer_cpu_utilization.threshold
  alarm_description   = "RDS Aurora cluster writer has ${var.writer_cpu_utilization.comparison_operator} ${var.writer_cpu_utilization.threshold}% CPU utilization"
  datapoints_to_alarm = var.writer_cpu_utilization.datapoints_to_alarm

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.rds_aurora_cluster.id
    Role                = "WRITER"
  }

  // Notifications actions
  alarm_actions = [var.cloudwatch_notification_arn]
  ok_actions    = [var.cloudwatch_notification_arn]

}

resource "aws_cloudwatch_metric_alarm" "reader_cpu_utilization" {
  alarm_name          = "${aws_rds_cluster.rds_aurora_cluster.id}-reader-cpu_utilization"
  comparison_operator = var.reader_cpu_utilization.comparison_operator
  evaluation_periods  = var.reader_cpu_utilization.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.reader_cpu_utilization.period
  statistic           = var.reader_cpu_utilization.statistic
  threshold           = var.reader_cpu_utilization.threshold
  alarm_description   = "RDS Aurora cluster reader has ${var.reader_cpu_utilization.comparison_operator} ${var.reader_cpu_utilization.threshold}% CPU utilization"
  datapoints_to_alarm = var.reader_cpu_utilization.datapoints_to_alarm

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.rds_aurora_cluster.id
    Role                = "READER"
  }

  // Notifications actions
  alarm_actions = [var.cloudwatch_notification_arn]
  ok_actions    = [var.cloudwatch_notification_arn]

}

// CloudWatch alarm if replica lag >= 2000ms
resource "aws_cloudwatch_metric_alarm" "replica_lag" {
  alarm_name          = "${aws_rds_cluster.rds_aurora_cluster.id}-reader-replica-lag"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "2000"
  alarm_description   = "RDS Aurora replica lag has >= 2000ms"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.rds_aurora_cluster.id
    Role                = "READER"
  }

  // Notifications actions
  alarm_actions = [var.cloudwatch_notification_arn]
  ok_actions    = [var.cloudwatch_notification_arn]

}