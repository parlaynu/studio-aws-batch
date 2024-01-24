## role the batch service runs as

resource "aws_iam_role" "batch_service" {
  name               = "${var.project_name}-batch-service"
  assume_role_policy = data.aws_iam_policy_document.batch_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
  ]
  tags = {
    Name = "${var.project_name}-batch-service"
  }
}

data "aws_iam_policy_document" "batch_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}



## role for spotfleet

resource "aws_iam_role" "spotfleet" {
  name = "${var.project_name}-spotfleet"
  assume_role_policy = data.aws_iam_policy_document.spotfleet_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
  ]
  tags = {
    Name = "${var.project_name}-spotfleet"
  }
}

data "aws_iam_policy_document" "spotfleet_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }
  }
}


## profile/role for managed EC2 instances

resource "aws_iam_instance_profile" "batch_ec2" {
  name = "${var.project_name}-batch-ec2"
  role = aws_iam_role.batch_ec2.name
  tags = {
    Name = "${var.project_name}-batch-ec2"
  }
  depends_on = [
    aws_iam_role_policy_attachment.batch_ec2
  ]
}

resource "aws_iam_role" "batch_ec2" {
  name = "${var.project_name}-batch-ec2"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Name = "${var.project_name}-batch-ec2"
  }
}

resource "aws_iam_role_policy_attachment" "batch_ec2" {
  role       = aws_iam_role.batch_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "batch_ec2_ssm" {
  role       = aws_iam_role.batch_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



## role for ECS container agent to run as
## - specified in the job definition as 'executionRoleArn'
## - https://docs.aws.amazon.com/batch/latest/userguide/execution-IAM-role.html

resource "aws_iam_role" "ecs_execution" {
  name               = "${var.project_name}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  tags = {
    Name = "${var.project_name}-ecs-execution"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


## role for the job container
## - specified in the job definition as 'jobRoleArn'
## - the command will run as this role

resource "aws_iam_role" "batch_job" {
  name               = "${var.project_name}-batch-job"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  tags = {
    Name = "${var.project_name}-batch-job"
  }
}

resource "aws_iam_role_policy_attachment" "batch_job_bucket" {
  role       = aws_iam_role.batch_job.name
  policy_arn = aws_iam_policy.bucket_io.arn
}

resource "aws_iam_role_policy_attachment" "batch_job_logs" {
  role       = aws_iam_role.batch_job.name
  policy_arn = aws_iam_policy.write_logs.arn
}

