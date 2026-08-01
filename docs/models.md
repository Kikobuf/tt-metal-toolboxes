# Running Model Demos

All commands assume you're inside a `tt-metal-release` or `tt-metal-source`
toolbox with `PYTHONPATH=/tt-metal` already set (the images set this for you)
and run from `/tt-metal`. These demos are pytest-based: export the model
(and optionally device) env vars, then run the matching demo file with
`pytest -k <case>`.

## Llama 3.3 70B (TP=32) — Galaxy only

```bash
export HF_MODEL=meta-llama/Llama-3.3-70B-Instruct
pytest models/demos/llama3_70b_galaxy/demo/text_demo.py -k "performance-batch-32"
```

## Qwen 2.5 / Llama / Mistral family — via tt_transformers

Most transformer-family models route through the shared `tt_transformers`
implementation rather than a per-model demo folder:

```bash
export HF_MODEL=Qwen/Qwen2.5-7B-Instruct
export MESH_DEVICE=N300
pytest models/tt_transformers/demo/simple_text_demo.py -k "performance and batch-1"
```

`MESH_DEVICE` is optional — set it only to run on fewer chips than are
available (`N150`, `N300`, `T3K`, `TG`). Swap it for your board and
`HF_MODEL` for any HF model ID supported by `tt_transformers` — check the
full matrix at
https://github.com/tenstorrent/tt-metal/blob/main/models/tt_transformers/README.md
before assuming a given model/board combination is supported.

## Mixtral 8x7B (TP=8)

```bash
export HF_MODEL=mistralai/Mixtral-8x7B-Instruct-v0.1
pytest models/tt_transformers/demo/simple_text_demo.py -k "performance and batch-1"
```

## Whisper (distil-large-v3)

```bash
pytest --disable-warnings models/demos/audio/whisper/demo/demo.py::test_demo_for_conditional_generation_dataset
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
