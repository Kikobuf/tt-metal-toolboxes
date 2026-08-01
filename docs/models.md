# Running Model Demos

All commands assume you're inside a `tt-metal-release` or `tt-metal-source`
toolbox with `PYTHONPATH=/tt-metal` already set (the images set this for you).

## Llama 3.3 70B (TP=32) — Galaxy only

```bash
python3 -m models.demos.llama3_70b_galaxy.demo.demo
```

## Qwen 2.5 / Llama / Mistral family — via tt_transformers

Most transformer-family models route through the shared `tt_transformers`
implementation rather than a per-model demo folder:

```bash
python3 -m models.tt_transformers.demo.demo \
  --model Qwen/Qwen2.5-7B-Instruct \
  --device n300
```

Swap `--device` for your board (`n150`, `n300`, `p150`, `p150x2`, `p150x8`,
`galaxy`) and `--model` for any HF model ID supported by `tt_transformers` —
check the full matrix at
https://github.com/tenstorrent/tt-metal/blob/main/models/README.md before
assuming a given model/board combination is supported.

## Mixtral 8x7B (TP=8)

```bash
python3 -m models.tt_transformers.demo.demo \
  --model mistralai/Mixtral-8x7B-Instruct-v0.1 \
  --device quietbox
```

## Whisper (distil-large-v3)

```bash
python3 -m models.demos.audio.whisper.demo.demo --device n150
```

## Finding the right demo path

The `models/demos/` and `models/tt_transformers/` folders in the upstream
`tt-metal` repo are the source of truth and change as new architectures land.
Inside the toolbox:

```bash
ls /tt-metal/models/demos
ls /tt-metal/models/tt_transformers
```

## Basic ttnn examples (no full model, just verifying the API works)

```bash
python3 -m ttnn.examples.usage.run_op_on_device
```

Useful as a smoke test right after `tt-smi` confirms the device is visible,
before jumping into a full model demo.
