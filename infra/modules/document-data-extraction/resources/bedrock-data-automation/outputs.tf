output "bda_project_arn" {
  description = "The ARN of the Bedrock Data Analytics project"
  value       = awscc_bedrock_data_automation_project.bda_project.project_arn
}

output "bda_role_name" {
  description = "The name of the IAM role used by Bedrock Data Analytics"
  value       = aws_iam_role.bda_role.name
}

output "bda_role_arn" {
  description = "The ARN of the IAM role used by Bedrock Data Analytics"
  value       = aws_iam_role.bda_role.arn
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