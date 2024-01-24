
resource "aws_cloudwatch_log_group" "helloworld" {
  name = "/${var.project_name}/job/helloworld"

  tags = {
    Name = "${var.project_name}-helloworld"
  }
}


resource "aws_batch_job_definition" "helloworld" {
  name = "${var.project_name}-helloworld"
  type = "container"

  platform_capabilities = [
    "EC2",
  ]
  
  container_properties = jsonencode({
    executionRoleArn = aws_iam_role.ecs_execution.arn

    image      = "${local.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}:job-helloworld-latest"
    command    = ["echo", "hello world"]
    jobRoleArn = aws_iam_role.batch_job.arn
    
    linuxParameters = {
      maxSwap = 0
      swappiness = 0
    }

    resourceRequirements = [
      {
        type  = "VCPU"
        value = "1"
      },
      {
        type  = "MEMORY"
        value = "1024"
      }
    ]
        
    # https://docs.aws.amazon.com/batch/latest/userguide/using_awslogs.html
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.helloworld.name
        awslogs-multiline-pattern = "^-----|^configuration|^setup|^\\d+ processing|^summary|^discovered|^resource|^Traceback|sleeping"
      }
    }

  })
  
  propagate_tags = true
  tags = {
    Name = "${var.project_name}-helloworld"
  }
}

