FROM nvcr.io/nvidia/sglang:25.10-py3

# Same image already proven working on jetson-thor's Tegra/Thor GPU for an
# existing voice-agent pipeline -- reused deliberately rather than
# introducing an unproven inference stack on brand-new hardware.

ENV HF_HOME=/opt/data/hf-cache

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
