#----------------
# Access Control
#----------------

resource "aws_iam_role" "task_executor" {
  name               = local.task_executor_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role_policy.json
}

resource "aws_iam_role" "app_service" {
  name               = "${var.service_name}-app"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role_policy.json
}

resource "aws_iam_role" "migrator_task" {
  count = var.db_vars != null ? 1 : 0

  name               = "${var.service_name}-migrator"
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
  dynamic "statement" {
    for_each = var.external_image_url == "" ? [true] : []
    content {
      sid = "ECRPullAccess"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
      ]
      resources = [data.aws_ecr_repository.app[0].arn]
    }
  }

  # Allow ECS to access Parameter Store for specific resources
  # But only include the statement if var.container_secrets is not empty
  # Strip any non-alphanumeric values from the secret name
  dynamic "statement" {
    for_each = var.container_secrets
    content {
      sid = "SSMAccess${replace(statement.value.name, "/[^0-9A-Za-z]/", "")}"
      actions = [
        "ssm:GetParameters",
      ]
      resources = [statement.value.valueFrom]
    }
  }
}

resource "aws_iam_role_policy" "task_executor" {
  name   = "${var.service_name}-task-executor-role-policy"
  role   = aws_iam_role.task_executor.id
  policy = data.aws_iam_policy_document.task_executor.json
}
