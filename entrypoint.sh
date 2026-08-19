#!/bin/sh
set -e

# tool-call-parser: this SGLang build (nvcr.io 25.10, sglang 0.5.3rc1) has
# no "hermes" choice at all (real error found live: "invalid choice:
# 'hermes'"). vLLM names its equivalent parser "hermes"; SGLang's is
# "qwen25" -- both read the same <tool_call> XML-tag format Hermes models
# emit, confirmed against Hermes-4's own model card.
exec python3 -m sglang.launch_server \
  --model-path "${SGLANG_MODEL:-NousResearch/Hermes-4-14B-FP8}" \
  --served-model-name "${SGLANG_MODEL_NAME:-hermes-4-14b}" \
  --host 0.0.0.0 --port 8080 \
  --enable-auto-tool-choice --tool-call-parser qwen25 \
  --context-length 32768
