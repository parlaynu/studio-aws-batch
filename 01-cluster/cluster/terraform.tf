# NOTE: the values below that begine with 'replace-' are replaced during the
#       container build process - variables can't be used in this location.
#       They are the correct values within the container.

terraform {
  required_version = "~> 1.5.7"

  backend "s3" {
    profile        = "replace-profile-name"
    bucket         = "replace-project-name-tfstate"
    key            = "replace-project-name-cluster"
    dynamodb_table = "replace-project-name-tfstate"
    region         = "replace-aws-region"
  }

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

