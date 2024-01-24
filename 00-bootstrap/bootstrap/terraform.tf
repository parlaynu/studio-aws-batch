# required environment variables:
#   AWS_PROFILE

terraform {
  required_version = "~> 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region = var.aws_region
  default_tags {
    tags = {
      Name = var.project_name
    }
  }
}

