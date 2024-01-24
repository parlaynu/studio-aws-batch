#!/usr/bin/env python3
import argparse
import os.path
import getpass
from pprint import pprint

from jobapi import list_jobs


def parse_cmdline():
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--profile', help='the aws profile to use', type=str, default=None)
    parser.add_argument('-a', '--all', help='list all queues', action='store_true')
    parser.add_argument('queue', help='the queue to ', type=str, default=None)
    parser.add_argument(
        'filters',
         help="filters regex expression (status='regex', user='regex')", 
         type=str, 
         nargs='*', 
         default=[]
    )
    args = parser.parse_args()

    if args.profile is not None:
        os.environ["AWS_PROFILE"] = args.profile

    return args


def main():
    args = parse_cmdline()
    
    # extract the filters
    status = 'SUBMITTED|PENDING|RUNNABLE|STARTING|RUNNING'
    user = getpass.getuser()
    
    for f in args.filters:
        if f.startswith('status='):
            status = f.removeprefix('status=')
        elif f.startswith('user='):
            user = f.removeprefix('user=')
        else:
            raise ValueError("filter must start with 'status=' or 'user='")
    
    user = user.lower()

    # all flag overrides any filters
    if args.all:
        user = 'all'
        status = 'all'
    
    if status == 'ALL' or status == 'all':
        status = 'SUBMITTED|PENDING|RUNNABLE|STARTING|RUNNING|SUCCEEDED|FAILED'
    status = status.split('|')

    # get the jobs
    jobs = []
    for s in status:
        print(f"checking {s}")
        js = list_jobs(args.queue, s, gettags=True)
        
        for j in js:
            ts = j.get('tags', None)
            if ts is None:
                jobs.append(j)
                continue
            
            u = ts.get('submitter', None)
            if u is None or user == 'all' or u.lower() == user:
                jobs.append(j)
    
    # 'jobArn': 'arn:aws:batch:ap-southeast-2:105207875814:job/db6e0a87-d86e-4d2e-9e84-b1d84b3c0fc9',
    # 'jobId': 'db6e0a87-d86e-4d2e-9e84-b1d84b3c0fc9',
    # 'jobName': 'arrayjob-1692581464',
    # 'createdAt': 1692581464632,
    # 'status': 'SUCCEEDED',
    # 'arrayProperties': {
    #   'size': 4
    # },
    # 'tags': {
    #   'submitter': 'paul'
    # }
    
    # format and display then
    print(f"number of jobs: {len(jobs)}")
    
    for j in jobs:
        pprint(j)
    

if __name__ == "__main__":
    main()

