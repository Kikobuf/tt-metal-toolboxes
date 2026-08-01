# tt-metal-source toolbox
#
# Builds tt-metal from source, pinned to a specific git ref (tag, branch, or
# commit). Use this when you need `main` for a feature/fix not yet in a
# release, or want to pin an exact commit for reproducibility.

FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/Kikobuf/tt-metal-toolboxes"
LABEL org.opencontainers.image.description="tt-metal built from source, packaged for toolbox/distrobox"

ARG TT_METAL_REF=v0.67.4
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        curl \
        git \
        vim \
        htop \
        cpufrequtils \
        build-essential \
        ninja-build \
        cmake \
        python3 \
        python3-pip \
        python3-venv \
        ca-certificates \
        && rm -rf /var/lib/apt/lists/*

WORKDIR /tt-metal

# Clone pinned ref with submodules
RUN git clone --recurse-submodules --branch ${TT_METAL_REF} --depth 1 \
        https://github.com/tenstorrent/tt-metal.git . \
    || (git clone --recurse-submodules https://github.com/tenstorrent/tt-metal.git . \
        && git checkout ${TT_METAL_REF} \
        && git submodule update --init --recursive)

# Host build dependencies (installs system packages tt-metal needs to compile)
RUN ./install_dependencies.sh || true

# Build (Option A from INSTALLING.md — recommended build script)
RUN ./build_metal.sh

# Python environment for model demos
RUN ./create_venv.sh
ENV PYTHONPATH=/tt-metal
ENV PATH="/tt-metal/python_env/bin:${PATH}"

RUN pip install --no-cache-dir -r tt_metal/python_env/requirements-dev.txt || true

CMD ["/bin/bash"]
