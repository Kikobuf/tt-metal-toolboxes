# tt-metal-release toolbox
#
# Thin wrapper around Tenstorrent's official release image so it can be used
# with `toolbox`/`distrobox` the same way the AMD Strix Halo and Intel iGPU
# toolboxes are used.
#
# Base image is rebuilt by Tenstorrent on every tt-metal release; this
# Dockerfile just adds toolbox-compatible entrypoint bits + convenience tools.

ARG TT_METAL_TAG=latest-rc
FROM ghcr.io/tenstorrent/tt-metal/tt-metalium-ubuntu-22.04-release-amd64:${TT_METAL_TAG}

LABEL org.opencontainers.image.source="https://github.com/Kikobuf/tt-metal-toolboxes"
LABEL org.opencontainers.image.description="tt-metal release image, packaged for toolbox/distrobox"

# toolbox/distrobox expects a few standard tools + a non-root user setup hook.
# See: https://containertoolbx.org/images/
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        curl \
        git \
        vim \
        htop \
        cpufrequtils \
        && rm -rf /var/lib/apt/lists/*

# Model demo dependencies (tt-metal/INSTALLING.md, Step 2: "For models users only")
RUN pip install --no-cache-dir -r /tt-metal/tt_metal/python_env/requirements-dev.txt || true

ENV PYTHONPATH=/tt-metal

# Performance governor should be set on the HOST, not here — see docs/host-config.md.
# This container assumes /dev/tenstorrent is passed through at `toolbox create` time.

WORKDIR /tt-metal
CMD ["/bin/bash"]
