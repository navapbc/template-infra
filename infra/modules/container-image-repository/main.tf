#
#
# To use the ECR repository, you'll need to grant the following permissions
# data "aws_iam_policy_document" "ecr-perms" {
#   statement {
#     sid = "ECRPerms"
#     actions = [
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:BatchGetImage",
#       "ecr:CompleteLayerUpload",
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:GetLifecyclePolicy",
#       "ecr:InitiateLayerUpload",
#       "ecr:PutImage",
#       "ecr:UploadLayerPart"
#     ]
#     effect = "Allow"
#     resources = [ "value" ]
#   }
# }
# 

locals {
  image_repository_name = "${var.project_name}-${var.app_name}"

  # Friendly path to put IAM policies created by this module
  iam_path = "/${var.project_name}/${var.app_name}/container-image-repository/"
}

resource "aws_ecr_repository" "app" {
  name = local.image_repository_name

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "image_retention" {
  repository = local.image_repository_name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Maintain a maximum of 200 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 200
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "push_access" {
  statement {
    sid = "PushAccess"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    effect    = "Allow"
    resources = ["${aws_ecr_repository.app.arn}"]
  }
}

data "aws_iam_policy_document" "pull_access" {
  statement {
    sid = "PullAccess"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    effect    = "Allow"
    resources = ["${aws_ecr_repository.app.arn}"]
  }
}

resource "aws_iam_policy" "push_access" {
  name        = "push-access"
  path        = local.iam_path
  description = "Allow push access to the ECR repository for ${var.app_name}"
  policy      = data.aws_iam_policy_document.push_access.json
}

resource "aws_iam_policy" "pull_access" {
  name        = "pull-access"
  path        = local.iam_path
  description = "Allow pull access to the ECR repository for ${var.app_name}"
  policy      = data.aws_iam_policy_document.pull_access.json
}
