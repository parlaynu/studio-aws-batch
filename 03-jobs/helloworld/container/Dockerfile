ARG IMG_REPOSITORY=local

FROM ${IMG_REPOSITORY}:ubuntu-2204-base-latest

RUN pip3 install --no-cache-dir numpy pillow opencv-python-headless

COPY local/src helloworld

