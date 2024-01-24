#!/usr/bin/env python3
import argparse
import os, time
import getpass
import uuid
from pprint import pprint

from jobapi import load_jobs, submit_job


def parse_cmdline():
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--profile', help='the aws profile to use', type=str, default=None)
    parser.add_argument('project', help='the project to submit to', type=str, default=None)
    parser.add_argument('jobfile', help='the job submission template', type=str, default=None)
    parser.add_argument('jobvars', help='job variables in key=value format', type=str, nargs='*', default=[])
    args = parser.parse_args()

    # special handling for the AWS profile
    if args.profile is not None:
        os.environ["AWS_PROFILE"] = args.profile

    jobfile = args.jobfile

    extra_vars = {}
    for jv in args.jobvars:
        k, v = jf.split("=", 1)
        extra_vars[k] = v
    
    jobvars = vars(args)
    del jobvars['jobfile']
    del jobvars['jobvars']
    del jobvars['profile']
    
    jobvars['username'] = getpass.getuser()
    jobvars['timestamp'] = int(time.time())
    jobvars['unique_id'] = str(uuid.uuid4())

    jobvars.update(extra_vars)
        
    return jobfile, jobvars


def main():
    # load the config and expand template
    jobfile, jobvars = parse_cmdline()
    
    jobs = load_jobs(jobfile, jobvars)
        
    # submit the jobs
    submitted = {}
    for job in jobs:

        # replace dependency keys with job ids
        if depends_on := job.get('depends_on', None):
            for dep in depends_on:
                if depname := dep.get('jobId', None):
                    dep['jobId'] = submitted[depname]
        
        print(f"submitting")
        for k, v in job.items():
            print(f"- {k}: {v}")

        jid = submit_job(**job)
        submitted[job['name']] = jid
        print(f"- jobid: {jid}")
        
        
if __name__ == "__main__":
    main()

