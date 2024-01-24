
/*resource "aws_batch_job_queue" "gpu_p1" {
  name     = "${var.project_name}-gpu-p1"
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.spot_gpu.arn,
  ]

  tags = {
    Name = "${var.project_name}-gpu-p1"
  }
}*/

resource "aws_batch_job_queue" "gpu_p3" {
  name     = "${var.project_name}-gpu-p3"
  state    = "ENABLED"
  priority = 3
  compute_environments = [
    aws_batch_compute_environment.spot_gpu.arn,
  ]

  tags = {
    Name = "${var.project_name}-gpu-p3"
  }
}

/*resource "aws_batch_job_queue" "gpu_p5" {
  name     = "${var.project_name}-gpu-p5"
  state    = "ENABLED"
  priority = 5
  compute_environments = [
    aws_batch_compute_environment.spot_gpu.arn,
  ]

  tags = {
    Name = "${var.project_name}-gpu-p5"
  }
}*/

resource "aws_batch_compute_environment" "spot_gpu" {
  compute_environment_name = "${var.project_name}-spot-gpu"

  compute_resources {
    type = "SPOT"
    spot_iam_fleet_role = aws_iam_role.spotfleet.arn
    bid_percentage = 40

    allocation_strategy = "SPOT_PRICE_CAPACITY_OPTIMIZED"

    instance_role = aws_iam_instance_profile.batch_ec2.arn
    instance_type = [
      "g4dn.xlarge"
    ]

    max_vcpus = 4
    min_vcpus = 0

    subnets = [ for item in aws_subnet.private: item.id ]

    ec2_key_pair = aws_key_pair.ssh_key.key_name
    security_group_ids  = [ aws_security_group.private.id ]

    launch_template {
      launch_template_name = aws_launch_template.spot_gpu.name
    }

    tags = {
      Name = "${var.project_name}-spot-gpu"
    }
  }

  service_role = aws_iam_role.batch_service.arn
  type         = "MANAGED"

  tags = {
    Name = "${var.project_name}-spot-gpu"
  }

  # need to explicitly depend on the batch service role - accessing
  #   the arn above doesn't seem to create it implicitly
  depends_on   = [
    aws_iam_role.batch_service,
    aws_iam_role.spotfleet
  ]
}

resource "aws_launch_template" "spot_gpu" {
  name = "${var.project_name}-spot-gpu"
  user_data = filebase64("templates/user-data.txt.tpl")
  update_default_version = true
}

