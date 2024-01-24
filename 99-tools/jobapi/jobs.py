import os.path
import uuid

from ruamel.yaml import YAML
from jinja2 import Environment, BaseLoader, FileSystemLoader, select_autoescape

import boto3


def load_jobs(job_file, job_vars):
    # load and render the template
    job_file = os.path.abspath(os.path.expanduser(job_file))
    job_dir = os.path.dirname(job_file)
    job_name = os.path.basename(job_file)

    env = Environment(
        loader=FileSystemLoader(job_dir),
        autoescape=select_autoescape()
    )
    template = env.get_template(job_name)

    template_data = template.render(job_vars)

    # parse the yaml string
    yaml = YAML(typ='safe')
    jobs = yaml.load(template_data)

    # transform the job from the yaml structure into what submit expects
    for job in jobs:
    
        # command: list[str]
        # - convert all to string
        if command := job.get('command', None):
            for idx, c in enumerate(command):
                command[idx] = str(c)

        # parameters: dict[str, str]
        # - convert values to string
        if params := job.get('parameters', None):
            for k, v in params.items():
                params[k] = str(v)
    
        # envvars: dict[str, str]
        # - convert values to string
        if envvars := job.get('envvars', None):
            for k, v in envvars.items():
                envvars[k] = str(v)
    
        # resources: dict[str, str]
        # - convert values to string
        if resources := job.get('resources', None):
            for k, v in resources.items():
                resources[k] = str(v)
    
        # depends_on: list[dict[str, str]]
        if depends_on := job.get('depends_on', None):
            pass
    
        # tags: dict[str, str]
        # - convert values to strings
        if tags := job.get('tags', None):
            for k, v in tags.items():
                tags[k] = str(v)
    
        # make sure the sbumitter is set
        tags = job.get('tags', {})
        if tags.get('submitter', None) is None:
            tags['submitter'] = getpass.getuser()

    # return the job(s)
    return jobs


def submit_job(
    queue,
    *,
    name,
    definition,
    command,
    array_size=0,
    timeout=None,
    parameters=None,
    envvars=None,
    resources=None,
    depends_on=None,
    tags=None
):

    # adapt into the structure that the AWS API wants
    kwargs = {}
    
    overrides = {}
    overrides['command'] = command.copy()
    
    if envvars is not None:
        envlist = []
        for k, v in envvars.items():
            envlist.append({
                'name': k,
                'value': v
            })
        overrides['environment'] = envlist

    if resources is not None:
        reslist = []
        for k, v in resources.items():
            reslist.append({
                'type': str(k),
                'value': str(v)
            })
        overrides['resourceRequirements'] = reslist
    
    kwargs['containerOverrides'] = overrides

    if parameters is not None:
        kwargs['parameters'] = parameters.copy()

    if depends_on is not None:
        kwargs['dependsOn'] = depends_on
    
    if tags is not None:
        kwargs['tags'] = tags.copy()
    
    if array_size > 0:
        kwargs['arrayProperties'] = {
            'size': array_size
        }
    
    if timeout is not None:
        kwargs['timeout'] = {
            'attemptDurationSeconds': timeout
        }
    
    batch = boto3.client('batch')

    resp = batch.submit_job(
        jobQueue=queue,
        jobName=name,
        jobDefinition=definition,
        **kwargs
    )

    return resp['jobId']


def list_jobs(queue_name, status='RUNNING', gettags=False):
    
    batch = boto3.client('batch')

    jobs = []
    
    resp = batch.list_jobs(jobQueue=queue_name, jobStatus=status)
    while True:
        jresp = resp['jobSummaryList']
        for j in jresp:
            jobs.append(j)
        
        next_token = resp.get('nextToken', None)
        if next_token is None:
            break
        
        resp = batch.list_jobs(
            jobQueue=queue.queue_name, 
            jobStatus=status,
            nextToken=next_token
        )
    
    if gettags:
        for j in jobs:
            tags = batch.list_tags_for_resource(resourceArn=j['jobArn'])
            j['tags'] = tags['tags']
    
    return jobs


