#-----------------
# ECS Exec Access
# See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html
#-----------------
resource "aws_iam_policy" "ecs_exec" {
  name        = "${var.service_name}-ecs-exec"
  description = "A policy to run ECS Exec"
  policy      = data.aws_iam_policy_document.ecs_exec.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec" {
  count      = var.enable_service_execution ? 1 : 0
  role       = aws_iam_role.app_service.name
  policy_arn = aws_iam_policy.ecs_exec.arn
}

data "aws_iam_policy_document" "ecs_exec" {
  # Allow ECS to access SSM Messages so that ECS Exec works
  # See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html
  statement {
    sid    = "SSMAccess"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }
}
