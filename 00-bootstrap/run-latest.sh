#!/usr/bin/env bash

if [[ $# -ne 1 || ( $# -eq 1 && "$1" == "-h" ) ]]; then
    echo "Usage: `basename $0` project-name"
    exit 1
fi

PROJECT_NAME="$1"

# run the container
TAG="${PROJECT_NAME}-bootstrap"

echo Running container image ${TAG}
docker run -it --rm --network=host \
    -v "${HOME}/.aws":/root/.aws \
    "${TAG}" /bin/bash

