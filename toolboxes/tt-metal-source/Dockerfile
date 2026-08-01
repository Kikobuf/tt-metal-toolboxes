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

# Host build dependencies (installs system packages tt-metal needs to compile).
# DEBIAN_FRONTEND=noninteractive (set above) is a Docker ENV, so it covers
# every apt-get call this script makes, not just the base image's own. The
# script itself also passes -y/-f to every apt-get/dpkg call it runs, so
# there's nothing here that can block on a prompt.
RUN echo "==> [1/4] Installing host build dependencies (install_dependencies.sh)" \
    && (./install_dependencies.sh || true) \
    && echo "==> [1/4] Done"

# Build (Option A from INSTALLING.md — recommended build script). build_metal.sh
# doesn't expose its own --verbose flag, but its underlying CMake-generated
# Ninja build honors the VERBOSE env var, printing each compile/link command
# instead of just a progress bar — so a hang and a slow build don't look the
# same in the Action log.
RUN echo "==> [2/4] Building tt-metal (build_metal.sh, this takes 30-60+ min)" \
    && VERBOSE=1 ./build_metal.sh \
    && echo "==> [2/4] Done"

# Python environment for model demos
RUN echo "==> [3/4] Creating Python venv (create_venv.sh)" \
    && ./create_venv.sh \
    && echo "==> [3/4] Done"
ENV PYTHONPATH=/tt-metal
ENV PATH="/tt-metal/python_env/bin:${PATH}"

RUN echo "==> [4/4] Installing model-demo Python requirements" \
    && (pip install --no-cache-dir -r tt_metal/python_env/requirements-dev.txt || true) \
    && echo "==> [4/4] Done"

CMD ["/bin/bash"]
