locals {
  alb_name = "${var.prefix}-${var.alb_name}"
}

# ALB for an API running in ECS
resource "aws_lb" "alb" {
  idle_timeout    = "120"
  internal        = false
  name            = "${var.prefix}-nava-api-alb"
  security_groups = [aws_security_group.alb.id]
  subnets         = var.subnets

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
  lifecycle {
    create_before_destroy = true

    # changing the description is a destructive change
    # just ignore it
    ignore_changes = [description]
  }

  name_prefix = "${var.prefix}-nava-alb-lb_group-"
  description = "Allow traffic to alb"
  vpc_id      = var.vpc_id

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
