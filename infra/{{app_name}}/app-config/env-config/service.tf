locals {
  service_config = {
    service_name             = "${var.app_name}-${var.environment}"
    region                   = var.default_region
    app_cpu                  = var.app_cpu
    task_cpu                 = var.task_cpu
    app_memory               = var.app_memory
    task_memory              = var.task_memory
    desired_instance_count   = var.service_desired_instance_count
    enable_command_execution = var.enable_command_execution

    extra_environment_variables = merge(
      local.default_extra_environment_variables,
      var.service_override_extra_environment_variables
    )

    secrets = local.secrets

    file_upload_jobs = {
      for job_name, job_config in local.file_upload_jobs :
      # For job configs that don't define a source_bucket, add the source_bucket config property
      job_name => merge({ source_bucket = local.bucket_name }, job_config)
    }

    ephemeral_write_volumes = []
  }
}
