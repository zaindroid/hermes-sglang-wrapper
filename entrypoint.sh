#!/bin/sh
set -e

# tool-call-parser: this SGLang build (nvcr.io 25.10, sglang 0.5.3rc1) has
# no "hermes" choice at all (real error found live: "invalid choice:
# 'hermes'"). vLLM names its equivalent parser "hermes"; SGLang's is
# "qwen25" -- both read the same <tool_call> XML-tag format Hermes models
# emit, confirmed against Hermes-4's own model card. No separate "enable"
# flag either (--enable-auto-tool-choice is vLLM's name, not recognized
# here -- specifying --tool-call-parser is itself sufficient).
#
# reasoning-parser: Hermes-4 is a hybrid-reasoning model, emitting
# optional <think>...</think> segments -- without a parser these would
# leak into the visible response instead of being split out as reasoning
# content. "qwen3" (not "qwen3-thinking") matches Hermes-4's *optional*
# thinking, closest available choice for a hybrid (not always-on) model.
# context-length: Hermes Agent itself hard-refuses any model reporting
# under 64,000 tokens of context ("Model X has a context window of ...
# which is below the minimum 64,000 required by Hermes Agent" -- real
# error hit live at 32768). 65536 is the smallest value that clears it.
exec python3 -m sglang.launch_server \
  --model-path "${SGLANG_MODEL:-NousResearch/Hermes-4-14B-FP8}" \
  --served-model-name "${SGLANG_MODEL_NAME:-hermes-4-14b}" \
  --host 0.0.0.0 --port 8080 \
  --tool-call-parser qwen25 \
  --reasoning-parser qwen3 \
  --context-length 65536
