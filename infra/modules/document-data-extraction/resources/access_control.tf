resource "aws_iam_policy" "bedrock_access" {
  name   = "${var.name}-access"
  policy = data.aws_iam_policy_document.bedrock_access.json
}

data "aws_iam_policy_document" "bedrock_access" {
  statement {
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:GetDataAutomationProject",
      "bedrock:StartDataAutomationJob",
      "bedrock:GetDataAutomationJob",
      "bedrock:ListDataAutomationJobs"
    ]
    effect = "Allow"
    resources = [
      awscc_bedrock_data_automation_project.bda_project.project_arn,
      "${awscc_bedrock_data_automation_project.bda_project.project_arn}/*"
    ]
  }
}
