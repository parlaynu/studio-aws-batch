FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip vim && \
    rm -rf /var/lib/apt/lists/*

ARG ARCHITECTURE=amd64
ARG TF_VERSION=1.5.7

ARG PROJECT_NAME=pname
ARG AWS_PROFILE=default
ARG AWS_REGION=ap-southeast-2

ENV TF_VAR_project_name=${PROJECT_NAME}
ENV TF_VAR_aws_profile=${AWS_PROFILE}
ENV TF_VAR_aws_region=${AWS_REGION}

RUN mkdir -p /workspace
WORKDIR /workspace

RUN wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${ARCHITECTURE}.zip && \
    unzip terraform_${TF_VERSION}_linux_${ARCHITECTURE}.zip && \
    mv terraform /usr/local/bin && \
    chmod 755 /usr/local/bin/terraform && \
    rm -f terraform_${TF_VERSION}_linux_${ARCHITECTURE}.zip

COPY bootstrap .

ENTRYPOINT ["/bin/sh", "-c", "exec \"$0\" \"$@\""]
CMD ["/bin/bash"]

