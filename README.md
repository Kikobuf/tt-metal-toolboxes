# Tenstorrent TT-Metal Toolboxes

Pre-built `toolbox`/`distrobox` containers for running LLMs and other models natively on
**Tenstorrent** accelerators (Wormhole n150/n300, Blackhole p150, Galaxy, QuietBox/LoudBox)
using **TT-Metalium** and **TT-NN** directly — no vLLM layer, no HF/PyTorch conversion glue.

This is the "close to the metal" counterpart to
[`tt-vllm-toolboxes`](https://github.com/Kikobuf/tt-vllm-toolboxes), which wraps Tenstorrent's
official vLLM fork instead. Use this repo if you want the native `tt-metal` model demos
(`models/demos/`, `models/tt_transformers/`) and don't need vLLM's OpenAI-compatible server,
continuous batching, or paged attention.

Companion projects:
- [`amd-strix-halo-toolboxes`](https://github.com/kyuz0/amd-strix-halo-toolboxes) — same idea, for AMD Ryzen AI Max "Strix Halo" iGPUs
- `intel-igpu-toolboxes` — same idea, for Intel Arc / integrated GPUs
- [`tt-vllm-toolboxes`](https://github.com/Kikobuf/tt-vllm-toolboxes) — Tenstorrent's vLLM fork, containerized

---

## Table of Contents

- [Supported Hardware](#supported-hardware)
- [Supported Toolboxes](#supported-toolboxes)
- [Quick Start](#quick-start)
- [Host Configuration](#host-configuration)
- [Driver / Firmware Compatibility](#driver--firmware-compatibility)
- [Running Model Demos](#running-model-demos)
- [Building Locally](#building-locally)
- [Keeping Updated](#keeping-updated)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Supported Hardware

| Board            | Architecture | Notes                                                |
| ---------------- | ------------- | ----------------------------------------------------- |
| n150             | Wormhole      | Single-chip PCIe card                                 |
| n300             | Wormhole      | Dual-chip PCIe card                                    |
| p150             | Blackhole     | Single-chip PCIe card — software optimization ongoing  |
| p150x2 / p150x8  | Blackhole     | Multi-card configs                                     |
| QuietBox/LoudBox | Wormhole      | Multi-card chassis, requires TT-Topology config        |
| Galaxy           | Wormhole      | 6U rackmount, large-scale TP                           |

Full hardware list: https://tenstorrent.com/hardware

## Supported Toolboxes

| Container Tag       | Source                                                     | Purpose / Notes                                                        |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------ |
| `tt-metal-release`   | Official `ghcr.io/tenstorrent/tt-metal` release image        | Fastest path. Matches upstream release cadence exactly.                 |
| `tt-metal-source`    | Built from source (`build_metal.sh`), pinned to a git ref     | For tracking `main`/dev branches or specific commits not yet released.  |
| `tt-metal-wheel`     | `pip install ttnn` on a slim Ubuntu base                      | Lightest weight. Python `ttnn` API only — no full model demo repo.      |

> These are containerized with `toolbox`/`distrobox`, matching the pattern used by
> `amd-strix-halo-toolboxes` and `intel-igpu-toolboxes`, so the workflow feels the same
> across all three hardware backends.

## Quick Start

**Prerequisites:** you must run Tenstorrent's `tt-installer` on the **host** first — see
[Host Configuration](#host-configuration). The container does not include the kernel driver
or firmware; those live on the host and are exposed to the container via `/dev/tenstorrent`.

### Option A: Release image (recommended)

```bash
toolbox create tt-metal-release \
  --image ghcr.io/kikobuf/tt-metal-toolboxes:release \
  -- --device /dev/tenstorrent --group-add video --security-opt seccomp=unconfined

toolbox enter tt-metal-release
```

*(Ubuntu users: use `distrobox create` / `distrobox enter` instead of `toolbox`.)*

### Option B: Source build (tracks main / specific tags)

```bash
toolbox create tt-metal-source \
  --image ghcr.io/kikobuf/tt-metal-toolboxes:source \
  -- --device /dev/tenstorrent --group-add video --security-opt seccomp=unconfined

toolbox enter tt-metal-source
```

### Check device visibility

Inside the toolbox:

```bash
tt-smi
```

You should see your board(s) listed with firmware/driver versions. If this fails, the
host-side driver/firmware setup is incomplete — see below.

### Run a model demo

```bash
export PYTHONPATH=$(pwd)
python3 -m models.demos.llama3_70b_galaxy.demo.demo   # example — see docs/models.md for the full list
```

---

## Host Configuration

Unlike AMD Strix Halo or Intel iGPUs, Tenstorrent boards are **discrete PCIe accelerators**
with dedicated on-card memory — there's no unified/shared system-memory tuning to do. The
host-side work instead is entirely about the kernel driver + firmware stack.

### 1. Run TT-Installer on the host (not in the container)

```bash
curl -fsSL https://github.com/tenstorrent/tt-installer/releases/download/v2.1.0/install.sh -O
chmod +x install.sh
./install.sh --install-container-runtime=no
```

This installs the kernel driver (TT-KMD), firmware (TT-Flash), and TT-SMI on the host.
The container only needs `/dev/tenstorrent` passed through — it does not need its own
copy of the kernel driver.

### 2. Pin versions to match your board

If you're on Galaxy (6U) or Blackhole, pin explicit versions instead of "latest":

```bash
./install.sh \
  --smi-version=v5.0.0 \
  --fw-version=19.8.1 \
  --kmd-version=2.8.0 \
  --install-container-runtime=no
```

See [Driver / Firmware Compatibility](#driver--firmware-compatibility) below for which
versions pair with which `tt-metal` release.

### 3. Multi-card systems (QuietBox / LoudBox)

Multi-card chassis need eth routing configured via **TT-Topology** before the container
will see all chips correctly:
https://github.com/tenstorrent/tt-topology

### 4. Virtual machines

If running inside a VM (e.g. for isolation or shared infrastructure), the **host**
hypervisor must have IOMMU enabled and expose a vIOMMU with DMA remapping to the guest:

- `intel_iommu=on` or `amd_iommu=on` on the host kernel
- vIOMMU enabled in the hypervisor config for the guest
- Guest must support Intel VT-d / AMD-Vi passthrough

Skipping this is the most common cause of "device not found" errors in virtualized setups.

---

## Driver / Firmware Compatibility

`tt-metal` releases pin exact FW/KMD/TT-SMI versions. A mismatch between the container's
`tt-metal` build and the host's installed driver/firmware is the single most common source
of "works in the demo video, not for me" issues — check this table before opening an issue.

| tt-metal release | FW version | KMD (driver) | TT-SMI  |
| ------------------ | ------------ | --------------- | --------- |
| 0.67.4 (latest stable) | 19.2.0    | 2.5.0           | 3.0.38    |
| 0.67.0              | 19.2.0     | 2.5.0            | 3.0.38    |
| 0.66.0              | 19.2.0     | 2.5.0            | 3.0.38    |
| 0.65.1              | 19.2.0     | 2.5.0            | 3.0.38    |
| 0.64.5              | 18.12.0    | 2.4.1            | 3.0.32    |
| 0.63.0              | 18.8.0     | 2.3.0            | 3.0.28    |
| 0.62.2              | 18.6.0     | 2.0.0            | 3.0.20    |

> Source of truth: https://github.com/tenstorrent/tt-metal/releases — check this before
> pinning a container tag to a specific `tt-metal` version.

**Rule of thumb:** upgrade host firmware/driver *before* upgrading the container image, not
after. A newer container against older host firmware is the most common failure mode.

---

## Running Model Demos

Reported performance in upstream `tt-metal` docs (input seq len 128, TT-Metalium demos,
not vLLM):

| Model                  | Hardware              | TTFT (ms) | T/S/U | T/S    |
| ------------------------ | ------------------------ | ----------- | ------- | -------- |
| Llama 3.3 70B (TP=32)   | Galaxy (Wormhole)       | 53          | 72.5    | 2268.8  |
| Qwen 2.5 7B (TP=2)      | n300 (Wormhole)         | 109         | 22.1    | 707.2   |
| Qwen 2.5 72B (TP=8)     | QuietBox (Wormhole)     | 223         | 15.4    | 492.8   |
| Mixtral 8x7B (TP=8)     | QuietBox (Wormhole)     | 122         | 24.9    | 796.8   |
| Whisper (distil-large-v3) | n150 (Wormhole)       | 163         | 105.0   | 105.0   |
| Whisper (distil-large-v3) | p150 (Blackhole)      | 63          | 263.4   | 263.4   |

Full model matrix: https://github.com/tenstorrent/tt-metal/blob/main/models/README.md

> Blackhole software optimization is still actively evolving — expect faster iteration
> and occasional regressions on p150/p150x2/p150x8 relative to Wormhole boards.

See [`docs/models.md`](docs/models.md) for exact `python3 -m models.demos....` invocations
per model, and [`docs/host-config.md`](docs/host-config.md) for the full host setup guide.

---

## Building Locally

You can build the containers yourself to pin a specific `tt-metal` git ref, customize
Python version, or add extra packages.

```bash
cd toolboxes/tt-metal-source
docker build --build-arg TT_METAL_REF=v0.67.4 -t tt-metal-toolboxes:source .
```

See [`docs/building.md`](docs/building.md) for details on build args and customization.

## Keeping Updated

```bash
./refresh-toolboxes.sh all
```

Rebuilds/pulls the latest images for all toolbox tags you have installed.

---

## Troubleshooting

- **`tt-smi` shows no devices** → host driver/firmware not installed, or `/dev/tenstorrent`
  not passed through to the container. Re-run `tt-installer` on the host.
- **Device found but hangs/crashes on first inference** → check the
  [Driver / Firmware Compatibility](#driver--firmware-compatibility) table; mismatched
  FW/KMD vs. container `tt-metal` version is the most common cause.
- **Works on Wormhole, broken on Blackhole** → expected for now; Blackhole optimization is
  actively in progress upstream. Check https://github.com/tenstorrent/tt-metal/issues for
  known Blackhole-specific issues before filing a new one.
- **Multi-card system only sees one chip** → configure eth routing via TT-Topology first.

---

## References

- [tenstorrent/tt-metal](https://github.com/tenstorrent/tt-metal) — upstream repo
- [tt-metal INSTALLING.md](https://github.com/tenstorrent/tt-metal/blob/main/INSTALLING.md)
- [tt-installer](https://github.com/tenstorrent/tt-installer)
- [tt-topology](https://github.com/tenstorrent/tt-topology)
- [Tenstorrent Developer Hub](https://tenstorrent.com/developers)
- [Tenstorrent Discord](https://discord.gg/tenstorrent)

## Support

This is a hobby project maintained in spare time, in the same spirit as
`amd-strix-halo-toolboxes` and `intel-igpu-toolboxes`. Issues and PRs welcome.
