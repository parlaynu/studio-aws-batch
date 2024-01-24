#!/usr/bin/env python3
import argparse
import sys, os
import argparse
import subprocess
import resource
import time
import humanize
import datetime as dt


def run_command(verbose, command, args):
    
    # format the command into a single list
    command = [command]
    if len(args) > 0:
        command.extend(args)
    
    # run the command and wait for it to complete
    if verbose:
        print("----- command starting -----", flush=True)

    start = time.time()
    result = subprocess.run(command)
    elapsed = dt.timedelta(seconds=time.time() - start)
    
    if verbose:
        print("----- command finished -----")
        print(f"- elapsed time: {humanize.precisedelta(elapsed)}", flush=True)

    # collect the resource usage
    rusage = resource.getrusage(resource.RUSAGE_CHILDREN)
    
    # log the resource usage
    if verbose:
        print("----- resource usage -----")
        for attr in sorted(filter(lambda x: x.startswith('ru_'), dir(rusage))):
            print(f"- {attr}: {getattr(rusage, attr)}")
        
    return result.returncode


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbose', help='print runtime information', action='store_true')
    parser.add_argument('command', help='the command to run', type=str)
    parser.add_argument('args', help='arguments for the command', type=str, nargs=argparse.REMAINDER)
    args = parser.parse_args()

    # set work directory
    workdir = os.getenv("APP_WORKDIR", None)
    if workdir is None:
        workdir = os.getenv("WORKDIR", None)
    if workdir is not None:
        os.chdir(workdir)
    
    # expand any 'env:XXX' arguments
    success = True
    for idx, arg in enumerate(args.args):
        if not arg.startswith('env:'):
            continue
            
        envar = arg.split(':')[1]
        enval = os.getenv(envar, None)
        if enval is None:
            success = False
            print(f"Error: missing required environment variable {envar}")
        
        args.args[idx] = enval
    
    # logging command line and environment
    if args.verbose:
        print("----- environment -----")
        for k, v in sorted(os.environ.items()):
            print(f"- {k}: {os.environ[k]}")

        print("----- command -----")
        print(f"- raw: {' '.join(sys.argv)}")
        print(f"- sub: {args.command} {' '.join(args.args)}", flush=True)
    
    
    if success == False:
        sys.exit(1)
    
    # run the command
    sys.exit(run_command(args.verbose, args.command, args.args))


if __name__ == "__main__":
    main()



