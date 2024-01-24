
resource "aws_s3_bucket" "platform_tfstate" {
  bucket        = "${var.project_name}-tfstate"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "platform_tfstate" {
  bucket = aws_s3_bucket.platform_tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "platform_tfstate" {
  name           = "${var.project_name}-tfstate"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_ecr_repository" "platform_bootstrap" {
  name                 = "${var.project_name}-bootstrap"
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = false
  }
}

