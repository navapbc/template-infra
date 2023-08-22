#----------------
# Access Control
#----------------

resource "aws_iam_role" "task_executor" {
  name               = local.task_executor_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role_policy.json
}

resource "aws_iam_role" "service" {
  name               = var.service_name
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_tasks_assume_role_policy" {
  statement {
    sid = "ECSTasksAssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_executor" {
  # Allow ECS to log to Cloudwatch.
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["${aws_cloudwatch_log_group.service_logs.arn}:*"]
  }

  # Allow ECS to authenticate with ECR
  statement {
    sid = "ECRAuth"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  # Allow ECS to download images.
  statement {
    sid = "ECRPullAccess"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = [data.aws_ecr_repository.app.arn]
  }
}

resource "aws_iam_role_policy" "task_executor" {
  name   = "${var.service_name}-task-executor-role-policy"
  role   = aws_iam_role.task_executor.id
  policy = data.aws_iam_policy_document.task_executor.json
}

#-----------------
# Database Access 
#-----------------

resource "aws_vpc_security_group_ingress_rule" "db_ingress_from_service" {
  count = var.db_vars != null ? length(var.db_vars.security_group_ids) : 0

  security_group_id = var.db_vars.security_group_ids[count.index]
  description       = "Allow inbound requests to database from ${var.service_name} service"

  from_port                    = tonumber(var.db_vars.connection_info.port)
  to_port                      = tonumber(var.db_vars.connection_info.port)
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_iam_role_policy_attachment" "app_db_access" {
  count = var.db_vars != null ? 1 : 0

  role       = aws_iam_role.service.name
  policy_arn = var.db_vars.access_policy_arn
}
