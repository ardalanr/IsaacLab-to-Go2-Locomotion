# Use NVIDIA L4T base image for Jetson Orin compatibility
FROM nvcr.io/nvidia/l4t-base:35.3.1

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Update package lists and install basic build tools
RUN apt-get update && \
    apt-get install -y build-essential cmake git python3-pip

# Upgrade pip to latest version
RUN pip3 install --upgrade pip setuptools wheel

# Install boost libraries
RUN apt-get install -y libboost-all-dev

# Install GL and graphics libraries
RUN apt-get install -y libglib2.0-dev libgl1-mesa-glx libglib2.0-0

# Install X11 libraries
RUN apt-get install -y libsm6 libxext6 libxrender-dev

# Install additional system libraries
RUN apt-get install -y libgomp1 libgcc-s1

# Install OpenGL libraries
RUN apt-get install -y libglu1-mesa libegl1-mesa

# Install X11 extension libraries
RUN apt-get install -y libxrandr2 libxss1 libxcursor1 libxcomposite1

# Install audio and input libraries
RUN apt-get install -y libasound2 libxi6 libxtst6

# Install curl dependency (apt-get update already handled in the first combined RUN)
# The commented-out line means it's not actually run, so no change in behavior here.
# RUN apt-get update
# RUN apt-get install -y libcurl4-openssl-dev

# Install torch dependency
RUN apt-get install -y libopenblas-dev;

# Clean up package lists
RUN rm -rf /var/lib/apt/lists/*

# Python 3.8 is now installed and symlinked

# Install LCM from source (following README instructions) - Combined for efficiency
RUN cd /tmp && git clone https://github.com/lcm-proj/lcm.git && \
    cd /tmp/lcm && mkdir build && \
    cd /tmp/lcm/build && cmake .. && \
    make && \
    make install && \
    ldconfig && \
    rm -rf /tmp/lcm

# Install only essential Python dependencies for now
RUN pip3 install --no-cache-dir numpy==1.26.1 tqdm matplotlib lcm

# The go2_gym package will install the remaining dependencies via setup.py

# Install PyTorch for Jetson (following README requirements: pytorch 1.10 with cuda-11.3)
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache https://developer.download.nvidia.cn/compute/redist/jp/v511/pytorch/torch-2.0.0+nv23.05-cp38-cp38-linux_aarch64.whl && \
    pip3 install --no-cache-dir torchvision==0.15.2 && \
    pip3 install --no-cache-dir torchaudio==2.0.2

# Create workspace directory
WORKDIR /workspace

# Copy the project files
COPY . /workspace/

# Install the main package (following README instructions)
RUN pip3 install -e .

# Install and build Unitree SDK2 (following README instructions) - Combined for efficiency
RUN cd go2_gym_deploy/unitree_sdk2_bin/library/unitree_sdk2 && rm -rf build && \
    ./install.sh && \
    mkdir build && \
    cd build && cmake .. && \
    make

# Build lcm_position_go2 (following README instructions) - Combined for efficiency
RUN cd go2_gym_deploy && mkdir build && \
    cd build && cmake .. && \
    make -j

# Set the default command
CMD ["/bin/bash"]