#!/usr/bin/env bash
#
# refresh-toolboxes.sh — pull the latest images for one or all tt-metal
# toolbox tags and recreate the corresponding toolbox/distrobox container.
#
# Usage:
#   ./refresh-toolboxes.sh all
#   ./refresh-toolboxes.sh release
#   ./refresh-toolboxes.sh source
#   ./refresh-toolboxes.sh wheel

set -euo pipefail

REGISTRY="${TT_METAL_TOOLBOXES_REGISTRY:-ghcr.io/kikobuf/tt-metal-toolboxes}"

# Detect toolbox vs distrobox (Fedora vs Ubuntu/others)
if command -v toolbox >/dev/null 2>&1; then
  TOOLCMD="toolbox"
elif command -v distrobox >/dev/null 2>&1; then
  TOOLCMD="distrobox"
else
  echo "Neither 'toolbox' nor 'distrobox' found on PATH. Install one first." >&2
  exit 1
fi

refresh_one() {
  local tag="$1"
  local container_name="tt-metal-${tag}"
  local image="${REGISTRY}:${tag}"

  echo "==> Refreshing ${container_name} (${image})"
  docker pull "${image}" || podman pull "${image}"

  if ${TOOLCMD} list 2>/dev/null | grep -q "${container_name}"; then
    echo "    Removing existing container ${container_name}"
    ${TOOLCMD} rm -f "${container_name}" || true
  fi

  echo "    Creating ${container_name}"
  ${TOOLCMD} create "${container_name}" \
    --image "${image}" \
    -- --device /dev/tenstorrent --group-add video --security-opt seccomp=unconfined

  echo "    Done. Enter with: ${TOOLCMD} enter ${container_name}"
}

TARGET="${1:-all}"

case "$TARGET" in
  all)
    refresh_one "release"
    refresh_one "source"
    refresh_one "wheel"
    ;;
  release|source|wheel)
    refresh_one "$TARGET"
    ;;
  *)
    echo "Unknown target: $TARGET" >&2
    echo "Usage: $0 [all|release|source|wheel]" >&2
    exit 1
    ;;
esac
