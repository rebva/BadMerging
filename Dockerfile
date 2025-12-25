FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Basic OS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv git ca-certificates \
    libglib2.0-0 libsm6 libxext6 libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Pip upgrade
RUN python3 -m pip install --upgrade pip

# PyTorch (CUDA 12.4 wheels)
RUN python3 -m pip install \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu124

# Core libs + OpenCLIP package (this provides create_model_and_transforms)
RUN python3 -m pip install \
    open-clip-torch \
    numpy tqdm pillow ftfy regex \
    scikit-learn pandas
RUN ln -sf /usr/bin/python3 /usr/local/bin/python

# Install repo python dependencies
COPY requirements.txt /app/requirements.txt
RUN python3 -m pip install -r /app/requirements.txt

# Default command: open a shell
CMD ["bash"]
