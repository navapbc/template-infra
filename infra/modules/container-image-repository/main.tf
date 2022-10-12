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
