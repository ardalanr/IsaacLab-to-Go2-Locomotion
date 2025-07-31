# Use NVIDIA L4T base image for Jetson Orin compatibility
FROM nvcr.io/nvidia/l4t-base:35.3.1

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Update package lists
RUN apt-get update

# Install basic build tools
RUN apt-get install -y build-essential cmake git

# # Install Python 3.8 from official Python.org (safer alternative)
# RUN apt-get install -y libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev

# # Download and install Python 3.8.18 from python.org
# RUN cd /tmp && \
#     wget https://www.python.org/ftp/python/3.8.18/Python-3.8.18.tgz && \
#     tar -xf Python-3.8.18.tgz && \
#     cd Python-3.8.18 && \
#     ./configure --enable-optimizations && \
#     make -j$(nproc) && \
#     make altinstall && \
#     cd / && \
#     rm -rf /tmp/Python-3.8.18*

# # Create symlinks for python3 and pip3
# RUN ln -sf /usr/local/bin/python3.8 /usr/local/bin/python3
# RUN ln -sf /usr/local/bin/pip3.8 /usr/local/bin/pip3

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

# # Install curl dependency
RUN apt-get update
# RUN apt-get install -y libcurl4-openssl-dev

# Install torch dependency
RUN apt-get install -y libopenblas-dev;

# Clean up package lists
RUN rm -rf /var/lib/apt/lists/*

# Python 3.8 is now installed and symlinked

# Install LCM from source (following README instructions)
RUN cd /tmp && git clone https://github.com/lcm-proj/lcm.git
RUN cd /tmp/lcm && mkdir build
RUN cd /tmp/lcm/build && cmake ..
RUN cd /tmp/lcm/build && make
RUN cd /tmp/lcm/build && make install
RUN ldconfig
RUN rm -rf /tmp/lcm

# Install only essential Python dependencies for now
RUN pip3 install --no-cache-dir numpy==1.26.1
RUN pip3 install --no-cache-dir tqdm
RUN pip3 install --no-cache-dir matplotlib
RUN pip3 install --no-cache-dir lcm

# The go2_gym package will install the remaining dependencies via setup.py

# Install PyTorch for Jetson (following README requirements: pytorch 1.10 with cuda-11.3)
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --no-cache https://developer.download.nvidia.cn/compute/redist/jp/v511/pytorch/torch-2.0.0+nv23.05-cp38-cp38-linux_aarch64.whl
RUN pip3 install --no-cache-dir torchvision==0.15.2
RUN pip3 install --no-cache-dir torchaudio==2.0.2

# Create workspace directory
WORKDIR /workspace

# Copy the project files
COPY . /workspace/

# Install the main package (following README instructions)
RUN pip3 install -e .

# Install and build Unitree SDK2 (following README instructions)
RUN cd go2_gym_deploy/unitree_sdk2_bin/library/unitree_sdk2 && rm -rf build
RUN cd go2_gym_deploy/unitree_sdk2_bin/library/unitree_sdk2 && ./install.sh
RUN cd go2_gym_deploy/unitree_sdk2_bin/library/unitree_sdk2 && mkdir build
RUN cd go2_gym_deploy/unitree_sdk2_bin/library/unitree_sdk2/build && cmake ..
RUN cd go2_gym_deploy/unitree_sdk2_bin/library/unitree_sdk2/build && make

# Build lcm_position_go2 (following README instructions)
RUN cd go2_gym_deploy
RUN cd go2_gym_deploy && mkdir build
RUN cd go2_gym_deploy/build && cmake ..
RUN cd go2_gym_deploy/build && make -j

# Set the default command
CMD ["/bin/bash"] 