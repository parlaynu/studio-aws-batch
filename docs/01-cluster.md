# Cluster Infrastructure

This builds the cluster infrastructure as described earlier. The docker and terraform files
are in the [01-cluster](../01-cluster) directory.

## Build Container Image

Building is quite simple from the user perspective, but there is a lot going on behind the scenes.

To build the docker container image:

    $ ./build.sh
    Usage: build.sh project-name aws-profile [aws-region]

This creates the container image with all the software and configuration settings required.

## Build Cluster Infrastructure

Run the container image just created with this command:

    $ ./run-latest.sh <project-name> <aws-profile>

This launches the container and runs 'bash':

    Running container image 620740277126.dkr.ecr.ap-southeast-2.amazonaws.com/project-name-bootstrap:cluster-latest
    root@eximius:/workspace# ls
    ansible.tf            batch_endpoints.tf  buckets.tf          job_helloworld.tf  templates
    batch_compute_cpu.tf  batch_network.tf    common_policies.tf  scripts            terraform.tf
    batch_compute_gpu.tf  batch_roles.tf      container_repo.tf   ssh.tf             variables.tf

From within the container, initialise the terraform environment:

    # terraform init

    Initializing the backend...

    Successfully configured the backend "s3"! Terraform will automatically
    use this backend unless the backend configuration changes.

    Initializing provider plugins...
    - Finding latest version of hashicorp/tls...
    - Finding latest version of hashicorp/external...
    - Finding hashicorp/aws versions matching "~> 5.30.0"...
    - Finding latest version of hashicorp/local...
    - Finding latest version of hashicorp/template...
    - Installing hashicorp/tls v4.0.5...
    - Installed hashicorp/tls v4.0.5 (signed by HashiCorp)
    - Installing hashicorp/external v2.3.2...
    - Installed hashicorp/external v2.3.2 (signed by HashiCorp)
    - Installing hashicorp/aws v5.30.0...
    - Installed hashicorp/aws v5.30.0 (signed by HashiCorp)
    - Installing hashicorp/local v2.4.1...
    - Installed hashicorp/local v2.4.1 (signed by HashiCorp)
    - Installing hashicorp/template v2.2.0...
    - Installed hashicorp/template v2.2.0 (signed by HashiCorp)

    Terraform has created a lock file .terraform.lock.hcl to record the provider
    selections it made above. Include this file in your version control repository
    so that Terraform can guarantee to make the same selections by default when
    you run "terraform init" in the future.

    Terraform has been successfully initialized!

And apply it:

    # terraform apply

The summary looks like this:

    Plan: 58 to add, 0 to change, 0 to destroy.

    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.

      Enter a value: 

Enter 'yes' and the build will proceed.

The gateway server needs to be configured to act as an actual gateway and forward traffic from the
private subnet to the internet. This is done with ansible:

    # ./local/ansible/run-ansible.sh

When this completes successfully, the cluster infrastructure is ready.

## Destroying the Cluster

To destroy the cluster, run the container again as in the previous section:

    $ ./run-latest.sh <project-name> <aws-profile>

The first thing to do is to connect the terraform state from the S3 backend:

    # terraform init

Once this completes, you can destroy the infrastructure:

    # terraform destroy

## Job Definitions

This demo setup creates a job definition for a job called 'helloworld'. It isn't ready to be run as we
still need to create the docker container image for the job. This is done in a later step.
