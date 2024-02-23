locals {
  secrets = [
    for secret in var.secrets :
    {
      name      = secret.name,
      valueFrom = secret.ssm_param_name
    }
  ]
}
