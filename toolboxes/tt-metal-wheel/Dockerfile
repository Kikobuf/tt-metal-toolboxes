# tt-metal-wheel toolbox
#
# Lightest-weight option: `pip install ttnn` on a slim base. Good for people
# who only want the ttnn Python API (custom op graphs, scripting) and don't
# need the full models/ demo repo or a from-source build.

FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/Kikobuf/tt-metal-toolboxes"
LABEL org.opencontainers.image.description="ttnn wheel install, packaged for toolbox/distrobox"

ARG TTNN_VERSION=""
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        curl \
        git \
        vim \
        htop \
        python3 \
        python3-pip \
        ca-certificates \
        && rm -rf /var/lib/apt/lists/*

# glibc 2.34+ required — Ubuntu 22.04 ships 2.35, so we're fine.
RUN if [ -n "$TTNN_VERSION" ]; then \
        pip install --no-cache-dir "ttnn==${TTNN_VERSION}"; \
    else \
        pip install --no-cache-dir ttnn; \
    fi

WORKDIR /workspace
CMD ["/bin/bash"]
