resource "aws_ecs_service" "app" {
  name             = "${var.app_name}-${var.environment_name}"
  task_definition  = aws_ecs_task_definition.app.arn
  cluster          = var.ecs_cluster_arn
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  desired_count    = var.desired_instance_count

  # WORKAROUND: Increase health check grace period to 5 minutes to account for
  # lag time in NLB starting to send requests to new tasks.
  health_check_grace_period_seconds = 300

  # Allow changes to the desired_count without differences in terraform plan.
  # This allows autoscaling to manage the desired count for us.
  lifecycle {
    ignore_changes = [desired_count]
  }

  # TODO(https://github.com/navapbc/template-infra/issues/152)
  # network_configuration {
  #   assign_public_ip = false
  #   subnets          = data.aws_subnet.app.*.id
  #   security_groups  = [aws_security_group.app.id]
  # }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.id
    container_name   = local.app_name
    container_port   = 1550
  }

  depends_on = [
    aws_lb_listener.listener,
    aws_iam_role_policy.task_executor,
  ]
}

resource "aws_ecs_task_definition" "app" {
  family                = "${local.app_name}-${var.environment_name}-server"
  execution_role_arn    = aws_iam_role.task_executor.arn
  task_role_arn         = aws_iam_role.api_service.arn
  container_definitions = var.container_definitions
  # container_definitions = templatefile(
  #   "${path.module}/container_definitions.json",
  #   {
  #     app_name                                   = local.app_name
  #     cpu                                        = "2048"
  #     memory                                     = module.constants.api_ram_size
  #     db_host                                    = aws_db_instance.default.address
  #     db_name                                    = aws_db_instance.default.name
  #     db_username                                = "pfml_api"
  #     docker_image                               = "${data.aws_ecr_repository.app.repository_url}:${var.service_docker_tag}"
  #     environment_name                           = var.environment_name
  #     enable_full_error_logs                     = var.enable_full_error_logs
  #     cloudwatch_logs_group_name                 = aws_cloudwatch_log_group.service_logs.name
  #     aws_region                                 = data.aws_region.current.name
  #     logging_level                              = var.logging_level
  #     release_version                            = var.release_version
  #     pdf_api_host                               = "http://${data.aws_lb.network_load_balancer.dns_name}:${var.pdf_api_nlb_port}"
  #   }
  # )

  cpu    = var.cpu
  memory = var.ram_size

  requires_compatibilities = ["FARGATE"]

  # Reference https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html
  network_mode = "awsvpc"
}
