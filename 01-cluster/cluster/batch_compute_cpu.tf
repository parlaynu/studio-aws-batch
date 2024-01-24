
/*resource "aws_batch_job_queue" "cpu_p1" {
  name     = "${var.project_name}-cpu-p1"
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.spot_cpu.arn,
  ]

  tags = {
    Name = "${var.project_name}-cpu-p1"
  }
}*/

resource "aws_batch_job_queue" "cpu_p3" {
  name     = "${var.project_name}-cpu-p3"
  state    = "ENABLED"
  priority = 3
  compute_environments = [
    aws_batch_compute_environment.spot_cpu.arn,
  ]

  tags = {
    Name = "${var.project_name}-cpu-p3"
  }
}

/*resource "aws_batch_job_queue" "cpu_p5" {
  name     = "${var.project_name}-cpu-p5"
  state    = "ENABLED"
  priority = 5
  compute_environments = [
    aws_batch_compute_environment.spot_cpu.arn,
  ]

  tags = {
    Name = "${var.project_name}-cpu-p5"
  }
}*/

resource "aws_batch_compute_environment" "spot_cpu" {
  compute_environment_name = "${var.project_name}-spot-cpu"

  compute_resources {
    type = "SPOT"
    spot_iam_fleet_role = aws_iam_role.spotfleet.arn
    bid_percentage = 60

    allocation_strategy = "SPOT_PRICE_CAPACITY_OPTIMIZED"

    instance_role = aws_iam_instance_profile.batch_ec2.arn
    instance_type = [
      "m3.medium",
      /*"c6i.xlarge",
      "c5.xlarge",
      "m6i.xlarge",
      "m5.xlarge",
      "m4.xlarge",*/
    ]
    
    max_vcpus = 4
    min_vcpus = 0

    subnets = [ for item in aws_subnet.private: item.id ]

    ec2_key_pair = aws_key_pair.ssh_key.key_name
    security_group_ids  = [ aws_security_group.private.id ]
    
    launch_template {
      launch_template_name = aws_launch_template.spot_cpu.name
    }

    tags = {
      Name = "${var.project_name}-spot-cpu"
    }
  }

  service_role = aws_iam_role.batch_service.arn
  type         = "MANAGED"

  tags = {
    Name = "${var.project_name}-spot-cpu"
  }

  # trying to fix dependency race condition
  depends_on   = [
    aws_iam_role.batch_service,
    aws_iam_role.spotfleet
  ]
}


resource "aws_launch_template" "spot_cpu" {
  name = "${var.project_name}-spot-cpu"
  user_data = filebase64("templates/user-data.txt.tpl")
  update_default_version = true
}

