#-----------------
# Background Jobs
#-----------------
# CloudWatch Event Rules and CloudWatch Event Targets that define event-based
# triggers for background jobs, such as jobs that trigger when a file is
# uploaded to an S3 bucket or jobs that trigger on a specified "cron" schedule.
#
# For each job configuration, there is a single event rule and an associated
# event target
#

# Event rules that trigger whenever an object is created in S3
# for a particular source bucket and object key prefix
resource "aws_cloudwatch_event_rule" "file_upload_jobs" {
  for_each = var.file_upload_jobs

  name        = "${local.cluster_name}-${each.key}"
  description = "File uploaded to bucket ${each.value.source_bucket} with path prefix ${each.value.path_prefix}"

  event_pattern = jsonencode({
    source      = ["aws.s3"],
    detail-type = ["Object Created"],
    detail = {
      bucket = {
        name = [each.value.source_bucket]
      },
      object = {
        key = [{
          prefix = each.value.path_prefix
        }]
      }
    }
  })
}

# Event target for each event rule that specifies what task command to run

resource "aws_cloudwatch_event_target" "document_upload_jobs" {
  for_each = var.file_upload_jobs

  target_id = "${local.cluster_name}-${each.key}"
  rule      = aws_cloudwatch_event_rule.file_upload_jobs[each.key].name
  arn       = aws_ecs_cluster.cluster.arn
  role_arn  = aws_iam_role.events.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.app.arn
    launch_type         = "FARGATE"

    # Configuring Network Configuration is required when the task definition uses the awsvpc network mode.
    network_configuration {
      subnets         = var.private_subnet_ids
      security_groups = [aws_security_group.app.id]
    }
  }

  input_transformer {
    input_paths = {
      bucket_name = "$.detail.bucket.name",
      object_key  = "$.detail.object.key",
    }

    # Shape the input event to match the match the Amazon ECS RunTask TaskOverride structure
    # see https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html#targets-specifics-ecs-task
    # and https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_TaskOverride.html
    #
    # We need to replace the unicode characters U+003C and U+003E with < and >, respectively since
    # jsonencode has encodes those special characters, which are needed for EventBridge input variables
    # see https://developer.hashicorp.com/terraform/language/functions/jsonencode and
    # https://github.com/hashicorp/terraform/pull/18871
    input_template = replace(replace(jsonencode({
      containerOverrides = [
        {
          name    = local.container_name,
          command = each.value.task_command
        }
      ]
    }), "\\u003c", "<"), "\\u003e", ">")
  }
}
