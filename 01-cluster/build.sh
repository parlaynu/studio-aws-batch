#!/usr/bin/env bash

if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage: `basename $0` project-name aws-profile [aws-region]"
    exit 1
fi

# cd to the correct location
RUN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${RUN_DIR}

# setup the variables needed
PROJECT_NAME="$1"
export AWS_PROFILE="$2"

if [[ $# -eq 3 ]]; then
    AWS_REGION="$3"
else
    AWS_REGION=$( aws configure get region )
fi

REPOSITORY=${PROJECT_NAME}-bootstrap
STAMP=$(date +%s)

# get AWS variables
ACCOUNT_ID=$( aws sts get-caller-identity --query "Account" --output text )
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# login to the registry
aws ecr get-login-password --region "${AWS_REGION}" | \
    docker login --username AWS --password-stdin "${ECR_REGISTRY}"

# create the tags
TAG1="${ECR_REGISTRY}/${REPOSITORY}:cluster-${STAMP}"
TAG2="${ECR_REGISTRY}/${REPOSITORY}:cluster-latest"

# run the build
docker build \
    --tag "${TAG1}" \
    --tag "${TAG2}" \
    --build-arg "PROJECT_NAME=${PROJECT_NAME}" \
    --build-arg "AWS_PROFILE=${AWS_PROFILE}" \
    --build-arg "AWS_REGION=${AWS_REGION}" \
    .

# push to the repository
docker push "${TAG1}"
docker push "${TAG2}"

