## the buckets that will be used

data "aws_s3_bucket" "ro_buckets" {
  for_each = toset(var.ro_buckets)
  bucket = each.value
}

data "aws_s3_bucket" "rw_buckets" {
  for_each = toset(var.rw_buckets)
  bucket = each.value
}

locals {
  
  ext_ro_buckets = [ for bucket in data.aws_s3_bucket.ro_buckets : bucket ]
  ext_rw_buckets = [ for bucket in data.aws_s3_bucket.rw_buckets : bucket ]
  
  ro_buckets = length(var.ro_buckets) == 0 ? tolist(aws_s3_bucket.inputs) : local.ext_ro_buckets
  rw_buckets = length(var.rw_buckets) == 0 ? flatten([aws_s3_bucket.workspace, aws_s3_bucket.outputs]) : local.ext_rw_buckets
}

resource "aws_iam_policy" "bucket_io" {
  name        = "${var.project_name}-bucket-io"
  policy      = data.aws_iam_policy_document.bucket_io.json
  tags = {
    Name = "${var.project_name}-bucket-io"
  }
}

data "aws_iam_policy_document" "bucket_io" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = flatten([
      [ for bucket in local.ro_buckets : bucket.arn ],
      [ for bucket in local.rw_buckets : bucket.arn ],
    ])
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = flatten([
      [ for bucket in local.ro_buckets : "${bucket.arn}/*" ],
      [ for bucket in local.rw_buckets : "${bucket.arn}/*" ]
    ])
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [ for bucket in local.rw_buckets: "${bucket.arn}/*" ]
  }
}

## some example buckets

resource "aws_s3_bucket" "inputs" {
  count  = length(var.ro_buckets) == 0 ? 1 : 0
  bucket = "${var.project_name}-inputs"

  force_destroy = false

  tags = {
    Name = "${var.project_name}-inputs"
  }
}

resource "aws_s3_bucket" "workspace" {
  count  = length(var.rw_buckets) == 0 ? 1 : 0
  bucket = "${var.project_name}-workspace"

  force_destroy = false

  tags = {
    Name = "${var.project_name}-workspace"
  }
}

resource "aws_s3_bucket" "outputs" {
  count  = length(var.rw_buckets) == 0 ? 1 : 0
  bucket = "${var.project_name}-outputs"

  force_destroy = false

  tags = {
    Name = "${var.project_name}-outputs"
  }
}

