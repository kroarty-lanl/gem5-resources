FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y update && apt -y upgrade && \
    apt -y install build-essential cmake openmpi-bin libopenmpi-dev git
