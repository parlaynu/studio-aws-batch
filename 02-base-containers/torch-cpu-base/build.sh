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
    AWS_REGION=$( aws --profile ${AWS_PROFILE} configure get region )
fi

REPOSITORY="${PROJECT_NAME}"
STAMP=$(date +%s)

mkdir -p local
cp ../helpers/run-wrapper.py local

ACCOUNT_ID=$( aws sts get-caller-identity --query "Account" --output text )

ECR_REGISTRY=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_REGISTRY}

docker build \
    --tag ${ECR_REGISTRY}/${REPOSITORY}:torch-1.11.0-0.12.0-cpu-base-${STAMP} \
    --tag ${ECR_REGISTRY}/${REPOSITORY}:torch-1.11.0-0.12.0-cpu-base-latest \
    .

docker push ${ECR_REGISTRY}/${REPOSITORY}:torch-1.11.0-0.12.0-cpu-base-${STAMP}
docker push ${ECR_REGISTRY}/${REPOSITORY}:torch-1.11.0-0.12.0-cpu-base-latest

