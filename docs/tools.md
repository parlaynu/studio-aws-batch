# Batch Tools

This provides some very simple tools to submit jobs and list jobs and queues. They're pretty
simple, but a reasonable starting point that lets you do real work with the cluster:

There are two python packages:

| Package  | Description                             |
| -------- | --------------------------------------- |
| jobapi   | python API to interact with the cluster |
| jobtools | tools that use the API                  |

The available tools are:

| Tool      | Desription                                                          |
| --------- | ------------------------------------------------------------------- |
| submit    | read and expand a template job file and submit a job for processing |
| lsqueues  | list all the available queues                                       |
| lsjobs    | list all the jobs running on a queue                                |

## Create The Environment

You need a python virtual environment setup to use these tools:

    python3 -m venv pyenv
    source pyenv/bin/activate

Install the tools and dependencies into the virtual environment:

    pip install .

## Tools

### Submit

The submit tool submits a job to the cluster. It reads a template job file (using jinja2), expands the variables in it,
and then submits it to the cluster. See the `jobs` directory for two example job templates.

    $ submit -h
    usage: submit [-h] [-p PROFILE] project jobfile [jobvars ...]
    
    positional arguments:
      project               the project to submit to
      jobfile               the job submission template
      jobvars               job variables in key=value format
      
    options:
      -h, --help            show this help message and exit
      -p PROFILE, --profile PROFILE
                            the aws profile to use

The `jobvars` argument is a way to pass variables from the command line into the `jinja2` template.

As an example:

    $ submit -p <aws-profile> <project> helloworld-array.yaml array_size=12

This would expand the job template 'helloworld-array.yaml' and override the default value for the 
variable `array_size` of 4 with 12.

### List Queues

List queues lists the queues available in the system:

    $ lsqueues -h
    usage: lsqueues [-h] [-p PROFILE] [-a] [-l]
    
    options:
      -h, --help            show this help message and exit
      -p PROFILE, --profile PROFILE
                            the aws profile to use
      -a, --all             list all queues
      -l, --long            list all attributes

An example run:

    $ lsqueues -p <aws-profile>
    moose-cpu-p3,ENABLED,VALID,JobQueue Healthy,3
    moose-gpu-p3,ENABLED,VALID,JobQueue Healthy,3

### List Jobs

Lists jobs in the system. The jobs returned can be filtered by the user that submitted them and the state.

    $ lsjobs -h
    usage: lsjobs [-h] [-p PROFILE] [-a] queue [filters ...]
    
    positional arguments:
      queue                 the queue to
      filters               filters regex expression (status='regex', user='regex')
      
    options:
      -h, --help            show this help message and exit
      -p PROFILE, --profile PROFILE
                            the aws profile to use
      -a, --all             list all queues

Valid status values for the filters are:

    SUBMITTED PENDING RUNNABLE STARTING RUNNING SUCCEEDED FAILED

These are used as shown below:

To list all jobs not completed:

    $ lsjobs -p <aws-profile> moose-gpu-p3
    checking SUBMITTED
    checking PENDING
    checking RUNNABLE
    checking STARTING
    checking RUNNING
    number of jobs: 0

To list jobs that are waiting to run:

    $ lsjobs -p <aws-profile> moose-gpu-p3 status=SUBMITTED|PENDING|RUNNABLE
    checking SUBMITTED
    checking PENDING
    checking RUNNABLE
    number of jobs: 0

To list all jobs that have succeeded:

    $ lsjobs -p <aws-profile> moose-gpu-p3 status=SUCCEEDED
    checking SUCCEEDED
    number of jobs: 145
    {'container': {'exitCode': 0},
     'createdAt': 1694579442280,
     'jobArn': 'arn:aws:batch:ap-southeast-2:105207875814:job/515fd795-b789-4504-ab34-750d7f91a4e3',
     'jobId': '515fd795-b789-4504-ab34-750d7f91a4e3',
     'jobName': 'mission-split-1694579441',
     'startedAt': 1694579445214,
     'status': 'SUCCEEDED',
     'statusReason': 'Essential container in task exited',
     'stoppedAt': 1694579447501,
     'tags': {'submitter': 'paul'}}
    {'container': {'exitCode': 0},
     'createdAt': 1694654078287,
     'jobArn': 'arn:aws:batch:ap-southeast-2:105207875814:job/cda1625d-b23a-4b41-a650-abb0439a744a',
     'jobId': 'cda1625d-b23a-4b41-a650-abb0439a744a',
     'jobName': 'mission-inference-1694654077',
     'startedAt': 1694654182144,
     'status': 'SUCCEEDED',
     'statusReason': 'Essential container in task exited',
     'stoppedAt': 1694654201299,
     'tags': {'submitter': 'paul'}}



