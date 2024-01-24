#!/usr/bin/env bash

if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage: `basename $0` project-name aws-profile [aws-region]"
    exit 1
fi

PROJECT_NAME="$1"
export AWS_PROFILE="$2"

if [[ $# -eq 3 ]]; then
    AWS_REGION="$3"
else
    AWS_REGION=$( aws configure get region )
fi

REPOSITORY="${PROJECT_NAME}"
STAMP=$(date +%s)

ACCOUNT_ID=$( aws sts get-caller-identity --query "Account" --output text )
ECR_REGISTRY=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# login to the registry
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_REGISTRY}

# create the tags
TAG="${ECR_REGISTRY}/${REPOSITORY}:job-helloworld-latest"

echo Running container image ${TAG}

docker run -it --rm --network=host \
    -v "${HOME}/.aws":/root/.aws \
    -e AWS_PROFILE=${AWS_PROFILE} \
    "${TAG}" /bin/bash
