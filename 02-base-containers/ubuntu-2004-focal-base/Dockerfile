FROM docker.io/ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-distutils git wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py && \
    rm -rf /root/.cache

RUN pip3 install --no-cache-dir humanize

COPY local/run-wrapper.py /usr/local/bin/run-wrapper.py

RUN mkdir -p /workspace
WORKDIR /workspace

ENTRYPOINT ["/bin/sh", "-c", "exec \"$0\" \"$@\""]
CMD ["/bin/bash"]
