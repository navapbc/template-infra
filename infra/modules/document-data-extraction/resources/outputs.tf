output "access_policy_arn" {
  description = "The ARN of the IAM policy for accessing the Bedrock Data Automation project"
  value       = aws_iam_policy.bedrock_access.arn
}

output "bda_project_arn" {
  description = "The ARN of the Bedrock Data Automation project"
  value       = awscc_bedrock_data_automation_project.bda_project.project_arn
}

output "bda_blueprint_arns" {
  value = [
    for key, bp in awscc_bedrock_blueprint.bda_blueprint : bp.blueprint_arn
  ]
}

output "bda_blueprint_names" {
  value = [
    for key, bp in awscc_bedrock_blueprint.bda_blueprint : bp.blueprint_name
  ]
}

output "bda_blueprint_arn_to_name" {
  value = {
    for key, bp in awscc_bedrock_blueprint.bda_blueprint : bp.blueprint_arn => bp.blueprint_name
  }
}