# syntax=docker/dockerfile:1.6

ARG BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04
FROM ${BASE_IMAGE}

# ---- Basic OS setup ----
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates curl wget \
    build-essential pkg-config \
    python3.11 python3.11-venv python3-pip \
    libjpeg-dev zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

# Make python/pip point to 3.11
RUN ln -sf /usr/bin/python3.11 /usr/local/bin/python && \
    python -m pip install --upgrade pip setuptools wheel

# ---- Create non-root user ----
ARG USERNAME=app
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USERNAME} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}

WORKDIR /app

# ---- Python deps ----
# If your repo has requirements.txt, this will use it.
# If not, we install common deps used by CLIP/OpenCLIP training.
COPY requirements.txt /app/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    if [ -f /app/requirements.txt ]; then \
        pip install --no-cache-dir -r /app/requirements.txt; \
    else \
        pip install --no-cache-dir \
            torch torchvision torchaudio \
            numpy scipy pandas tqdm pillow opencv-python \
            scikit-learn matplotlib \
            ftfy regex sentencepiece \
            timm \
            open_clip_torch; \
    fi

# ---- Copy source code ----
COPY . /app

# ---- Cache dirs (avoid writing to random places) ----
ENV HF_HOME=/app/.cache/huggingface \
    TORCH_HOME=/app/.cache/torch \
    XDG_CACHE_HOME=/app/.cache \
    PYTHONUNBUFFERED=1

RUN mkdir -p /app/.cache && chown -R ${USERNAME}:${USERNAME} /app

USER ${USERNAME}

# Default: show help-ish
CMD ["bash", "-lc", "ls -la && echo 'Ready. Try: bash finetune_clean.sh'"]
