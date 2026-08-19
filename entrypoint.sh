#!/bin/sh
set -e

exec python3 -m sglang.launch_server \
  --model-path "${SGLANG_MODEL:-NousResearch/Hermes-4-14B-FP8}" \
  --served-model-name "${SGLANG_MODEL_NAME:-hermes-4-14b}" \
  --host 0.0.0.0 --port 8080 \
  --enable-auto-tool-choice --tool-call-parser hermes \
  --context-length 32768
