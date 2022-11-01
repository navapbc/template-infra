data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  service_name            = "${var.app_name}-${var.environment_name}"
  alb_name                = local.service_name
  cluster_name            = local.service_name
  log_group_name          = "service/${local.service_name}"
  task_executor_role_name = "${local.service_name}-task-executor"
}

###########################
## Network Configuration ##
###########################


###################
## Load balancer ##
###################

# ALB for an API running in ECS
resource "aws_lb" "alb" {
  name            = local.alb_name
  idle_timeout    = "120"
  internal        = false
  security_groups = [aws_security_group.alb.id]
  subnets         = var.subnet_ids
}

# NOTE: for the demo we expose private http endpoint
# due to the complexity of acquiring a valid TLS/SSL cert.
# In a production system we would provision an https listener
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "api_http_forward" {
  listener_arn = aws_lb_listener.alb_listener_http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}


resource "aws_lb_target_group" "api_tg" {
  # you must use a prefix, to facilitate successful tg changes
  name_prefix          = "api-"
  port                 = "8080"
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = "30"

  health_check {
    path                = "/health"
    port                = 8080
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 30
    timeout             = 29
    matcher             = "200-299"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "alb" {
  name        = local.alb_name
  description = "Allow traffic to alb"

  lifecycle {
    create_before_destroy = true

    # changing the description is a destructive change
    # just ignore it
    ignore_changes = [description]
  }

  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#######################
## Service Execution ##
#######################

resource "aws_ecs_cluster" "cluster" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "app" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.cluster.arn
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_instance_count

  # Allow changes to the desired_count without differences in terraform plan.
  # This allows autoscaling to manage the desired count for us.
  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    assign_public_ip = false
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.app.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_tg.arn
    container_name   = local.service_name
    container_port   = 1550
  }
}

resource "aws_ecs_task_definition" "app" {
  family             = local.service_name
  execution_role_arn = aws_iam_role.task_executor.arn

  # when is this needed?
  # task_role_arn      = aws_iam_role.api_service.arn
  container_definitions = templatefile(
    "${path.module}/container-definitions.json.tftpl",
    {
      container_name            = local.service_name
      image_url                 = var.image_url
      container_port            = var.container_port
      cpu                       = var.cpu
      memory                    = var.memory
      environment_name          = var.environment_name
      cloudwatch_log_group_name = aws_cloudwatch_log_group.service_logs.name
      aws_region                = data.aws_region.current.name
    }
  )

  cpu    = var.cpu
  memory = var.memory

  requires_compatibilities = ["FARGATE"]

  # Reference https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html
  network_mode = "awsvpc"
}

# Security group to allow access to Fargate tasks
resource "aws_security_group" "app" {
  name        = local.service_name
  description = "allow inbound access on the container port"
  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = aws_security_group.alb.id
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "task_executor" {
  name               = local.task_executor_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    sid = "ECSTaskExecution"
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Cloudwatch log group to for streaming ECS application logs.
resource "aws_cloudwatch_log_group" "service_logs" {
  name = local.log_group_name
}
