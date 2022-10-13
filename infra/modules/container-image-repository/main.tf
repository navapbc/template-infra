#
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

data "aws_iam_policy_document" "ecr_access" {
  statement {
    sid    = "PushAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.push_access_role_arn]
    }
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
  }

  statement {
    sid    = "PullAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [for account_id in var.app_account_ids : "arn:aws:iam::${account_id}:root"]
    }
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
  }
}
