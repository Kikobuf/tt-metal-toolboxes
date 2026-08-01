# AGENTS.md

Context for AI coding agents (Claude Code, etc.) working on this repo.

## What this repo is

Containerized `toolbox`/`distrobox` images for running Tenstorrent's native
TT-Metalium/TT-NN stack (not vLLM — see the sibling `tt-vllm-toolboxes` repo
for that). Modeled after `kyuz0/amd-strix-halo-toolboxes` and
`Kikobuf/intel-igpu-toolboxes`.

## Key facts to keep in mind when editing

- Tenstorrent boards are discrete PCIe accelerators with fixed on-card DRAM —
  there is no unified-memory GTT-style tuning like Strix Halo/Intel iGPUs need.
  Don't port over VRAM-estimator logic from those repos; it doesn't apply here.
- The host driver/firmware stack (TT-KMD, TT-Flash, TT-SMI) is installed via
  Tenstorrent's `tt-installer` script, **on the host**, not in the container.
  Containers only need `/dev/tenstorrent` passed through.
- `tt-metal` releases hard-pin FW/KMD/TT-SMI versions. Any change to the
  container's `tt-metal` version should be reflected in
  `README.md#driver--firmware-compatibility` and cross-checked against
  https://github.com/tenstorrent/tt-metal/releases.
- Three toolbox variants exist on purpose: `release` (official prebuilt image,
  default recommendation), `source` (pinned git ref build, for main/dev
  branches), `wheel` (pip-only, lightest weight). Don't collapse these into
  one — they serve different audiences.
- Blackhole (`p150`/`p150x2`/`p150x8`) software support is explicitly called
  out upstream as still under active development. Don't claim parity with
  Wormhole in docs; flag it as evolving.

## Things NOT to do

- Don't add a `GGML_TENSTORRENT` llama.cpp build path — it doesn't exist
  upstream. This repo wraps TT-Metal's own model demos, not llama.cpp.
- Don't merge this repo's scope with `tt-vllm-toolboxes`. They're intentionally
  separate because they serve different runtime stacks (native TT-Metal vs.
  vLLM's OpenAI-compatible server / continuous batching).
