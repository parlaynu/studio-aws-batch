#!/usr/bin/env python3
import os.path
import argparse
from pprint import pprint

from jobapi import list_queues


def parse_cmdline():
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--profile', help='the aws profile to use', type=str, default=None)
    parser.add_argument('-a', '--all', help='list all queues', action='store_true')
    parser.add_argument('-l', '--long', help='list all attributes', action='store_true')
    args = parser.parse_args()
    
    if args.profile is not None:
        os.environ["AWS_PROFILE"] = args.profile

    return args


def main():
    args = parse_cmdline()
    
    queues = list_queues(args.all)
    
    # some formatting for reporting
    qs = {}
    for q in queues:
        qs[q['jobQueueName']] = q
        
    keys = list(qs.keys())
    keys.sort()
    
    for _, q in sorted(qs.items()):
        print(f"{q['jobQueueName']},{q['state']},{q['status']},{q['statusReason']},{q['priority']}")
        
        if args.long:
            print(f"  arn:")
            print(f"     {q['jobQueueArn']}")
            print(f"  compute env:")
            for ce in q['computeEnvironmentOrder']:
                print(f"    {ce['computeEnvironment']}")
            print(f"  tags:")
            
            tags = q['tags']
            for tk, tv in sorted(tags.items()):
                print(f"    {tk} = {tv}")
            
            print("")


if __name__ == "__main__":
    main()
