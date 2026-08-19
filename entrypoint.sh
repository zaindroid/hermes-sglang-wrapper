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
# context-length: tried bumping this to 65536 to clear Hermes Agent's
# hard 64K-minimum requirement -- real error found live: SGLang refuses
# to start, "User-specified context_length (65536) is greater than the
# derived context_length (40960)". 40960 is Hermes-4-14B's (Qwen3-
# architecture) actual native max -- confirmed the SAME real limit hits
# NousResearch/Hermes-4-14B and the separately-run Qwen3-32B-AWQ SGLang
# instance on rtx5090, so this isn't a fluke, it's Qwen3's real ceiling.
# SGLang's own override env var (SGLANG_ALLOW_OVERWRITE_LONGER_CONTEXT_LEN=1)
# exists but its error text explicitly warns this "may lead to incorrect
# model outputs or CUDA errors" -- deliberately NOT setting it here.
# Net effect: this model cannot satisfy Hermes Agent's 64K floor at all
# without accepting that risk. 40960 is the honest, stable ceiling.
exec python3 -m sglang.launch_server \
  --model-path "${SGLANG_MODEL:-NousResearch/Hermes-4-14B-FP8}" \
  --served-model-name "${SGLANG_MODEL_NAME:-hermes-4-14b}" \
  --host 0.0.0.0 --port 8080 \
  --tool-call-parser qwen25 \
  --reasoning-parser qwen3 \
  --context-length 40960
