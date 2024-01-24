#!/usr/bin/env bash

if [[ $# -lt 2 || $# -gt 3 || ( $# -eq 1 && "$1" == "-h" ) ]]; then
    echo "Usage: `basename $0` project-name aws-profile"
    exit 1
fi

PROJECT_NAME="$1"
AWS_PROFILE="$2"

if [[ $# -eq 3 ]]; then
    AWS_REGION="$3"
else
    AWS_REGION=$( aws --profile ${AWS_PROFILE} configure get region )
fi

REPOSITORY=${PROJECT_NAME}-bootstrap


# get AWS variables
ACCOUNT_ID=$( aws --profile ${AWS_PROFILE} sts get-caller-identity --query "Account" --output text )
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# login to the registry
aws --profile ${AWS_PROFILE} ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_REGISTRY}

# create the tags
TAG="${ECR_REGISTRY}/${REPOSITORY}:cluster-latest"

echo Running container image ${TAG}

docker run -it --rm --network=host \
    -v "${HOME}/.aws":/root/.aws \
    "${TAG}" /bin/bash


