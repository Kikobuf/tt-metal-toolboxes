# Building Locally

## tt-metal-release

Pin a specific upstream release tag instead of `latest-rc`:

```bash
docker build \
  --build-arg TT_METAL_TAG=v0.67.4 \
  -t tt-metal-toolboxes:release-0.67.4 \
  toolboxes/tt-metal-release
```

Available tags: https://github.com/orgs/tenstorrent/packages?q=tt-metalium-ubuntu

## tt-metal-source

Pin a git ref (tag, branch, or commit SHA):

```bash
docker build \
  --build-arg TT_METAL_REF=v0.67.4 \
  -t tt-metal-toolboxes:source-0.67.4 \
  toolboxes/tt-metal-source

# or track main:
docker build \
  --build-arg TT_METAL_REF=main \
  -t tt-metal-toolboxes:source-main \
  toolboxes/tt-metal-source
```

Note: source builds take significantly longer (expect 30-60+ minutes depending
on hardware) since they compile the full C++ tt_metal + ttnn stack.

## tt-metal-wheel

```bash
docker build \
  --build-arg TTNN_VERSION=0.67.4 \
  -t tt-metal-toolboxes:wheel-0.67.4 \
  toolboxes/tt-metal-wheel

# or latest published wheel:
docker build -t tt-metal-toolboxes:wheel-latest toolboxes/tt-metal-wheel
```

## Pushing to your own registry

```bash
docker tag tt-metal-toolboxes:release-0.67.4 ghcr.io/<you>/tt-metal-toolboxes:release-0.67.4
docker push ghcr.io/<you>/tt-metal-toolboxes:release-0.67.4
```

Update the `toolbox create --image` reference in your Quick Start commands to
point at your own registry if you don't want to depend on a shared upstream
image.
