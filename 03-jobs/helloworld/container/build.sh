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

# copy the src into place
mkdir local
cp -r ../src local

# registry 
ACCOUNT_ID=$( aws sts get-caller-identity --query "Account" --output text )
ECR_REGISTRY=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_REGISTRY}

# build the image
docker build \
    --tag ${ECR_REGISTRY}/${REPOSITORY}:job-helloworld-${STAMP} \
    --tag ${ECR_REGISTRY}/${REPOSITORY}:job-helloworld-latest \
    --build-arg IMG_REPOSITORY=${ECR_REGISTRY}/${REPOSITORY} \
    .

docker push ${ECR_REGISTRY}/${REPOSITORY}:job-helloworld-${STAMP}
docker push ${ECR_REGISTRY}/${REPOSITORY}:job-helloworld-latest

rm -rf local
