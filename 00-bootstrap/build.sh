#!/usr/bin/env bash

if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage: `basename $0` project-name aws-profile [aws-region]"
    exit 1
fi

# cd to the correct location
RUNDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${RUNDIR}

# setup the variables needed
PROJECT_NAME="$1"
export AWS_PROFILE="$2"

if [[ $# -eq 3 ]]; then
    AWS_REGION="$3"
else
    AWS_REGION=$( aws configure get region )
fi

# run the build
TAG="${PROJECT_NAME}-bootstrap"

docker build \
    --tag "${TAG}" \
    --build-arg "PROJECT_NAME=${PROJECT_NAME}" \
    --build-arg "AWS_PROFILE=${AWS_PROFILE}" \
    --build-arg "AWS_REGION=${AWS_REGION}" \
    .

