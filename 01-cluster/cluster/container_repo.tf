
resource "aws_ecr_repository" "main" {
  name                 = "${var.project_name}"
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = false
  }
}

