# Boostrap the Environment

The tools for bootstrapping the environment can be found in the [00-bootstrap](../00-bootstrap) directory.

It creates the infrastructure for storing terraform state in the 
[S3 backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3).
This requires an S3 bucket to store the state files and a DynamoDB table for managing locks to coordinate
access to the state files.

It also creates an ECR repository used to store admin containers used to build the demo environment.

The full resources created are listed in the table below. The 'project-name' is specified as an argument 
to the build script.

| Resource       | Name                   |
| -------------- | ---------------------- |
| S3 Bucket      | project-name-tfstate   |
| DynamoDB Table | project-name-tfstate   |
| ECR Repository | project-name-bootstrap |

It is designed to be run once and then discarded. It can easily be cleaned up manually in the AWS console
if necessary.

## Building

To build the container image:

    ./build.sh <project-name> <aws-profile> [<aws-region>]

The `project-name` parameter is used to prefix all infrastructure and is also used in dependent projects 
to locate infrastructure. By default, the region as configured with the profile is used; this can be overridden
by providing a region on the command line.

This creates the docker container image and leaves in the local docker environment - it can't push it up 
to an ECR repository because it hasn't been created yet.

To run the image:

    ./run-latest.sh <project-name>

Then from within the container, run terraform to create the bootstrap resources:

    terraform init
    terraform apply

You will be able to use the AWS console to browse and see the created resources.

