# Jetson Orin Deployment Guide

This guide explains how to deploy your Go2 RL walking policy on the NVIDIA Jetson Orin using Docker.

## Overview

The Jetson Orin runs Ubuntu 20.04, but LCM (Lightweight Communications and Marshalling) requires Ubuntu 22.04+. To solve this compatibility issue, we use Docker with the NVIDIA L4T 35.3.1 base image, which provides:

- Ubuntu 22.04 environment for LCM compatibility
- Python 3.8 as required by the project
- Pre-configured CUDA and NVIDIA drivers
- PyTorch 1.10 with CUDA 11.3 (as specified in README)
- Unitree SDK2 installation and build
- All necessary dependencies for the RL deployment

## Prerequisites

### On the Jetson Orin:

1. **Install Docker** (if not already installed):
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   # Log out and back in
   ```

2. **Install NVIDIA Container Toolkit**:
   ```bash
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
   sudo apt-get update
   sudo apt-get install -y nvidia-docker2
   sudo systemctl restart docker
   ```

3. **Verify NVIDIA Container Toolkit**:
   ```bash
   sudo docker run --rm --gpus all nvidia/cuda:11.6-base-ubuntu20.04 nvidia-smi
   ```

## Deployment Steps

### 1. Build the Docker Image

Run the deployment script:
```bash
chmod +x deploy_on_jetson_jetson.sh
./deploy_on_jetson_jetson.sh
```

Or build manually:
```bash
docker build -t go2-rl-deploy-jetson .
```

### 2. Run the Container

#### Option A: Interactive Mode
```bash
docker run -it --privileged --network host --gpus all go2-rl-deploy-jetson
```

#### Option B: Using Docker Compose
```bash
docker-compose up -d
docker-compose exec go2-rl-deploy bash
```

### 3. Inside the Container

#### Test Network Connection
First, verify the robot connection:
```bash
ping 192.168.123.161
```

Check your network interface:
```bash
ip addr show
```

#### Test LCM Communication
```bash
cd go2_gym_deploy/build
sudo ./lcm_receive
```

If you see LCM messages, the communication is working.

#### Start LCM Position Control
```bash
cd go2_gym_deploy/build
sudo ./lcm_position_go2 eth0  # Replace 'eth0' with your interface
```

Press Enter several times to initialize the communication.

#### Deploy the Policy
```bash
cd go2_gym_deploy/scripts
python3 deploy_policy.py
```

Press R2 on the controller to start the walking policy.

## Troubleshooting

### Common Issues

1. **Docker Permission Denied**:
   ```bash
   sudo usermod -aG docker $USER
   # Log out and back in
   ```

2. **NVIDIA Container Toolkit Not Working**:
   ```bash
   sudo systemctl restart docker
   sudo docker run --rm --gpus all nvidia/cuda:11.6-base-ubuntu20.04 nvidia-smi
   ```

3. **Network Interface Issues**:
   ```bash
   # Check available interfaces
   ip addr show
   # Use the correct interface name in lcm_position_go2 command
   ```

4. **LCM Communication Fails**:
   - Verify ethernet cable connection
   - Check robot IP address (default: 192.168.123.161)
   - Ensure robot is powered on and in low-level mode

5. **PyTorch/CUDA Issues**:
   The container uses pre-built PyTorch wheels for Jetson. If you encounter issues:
   ```bash
   # Inside container
   python3 -c "import torch; print(torch.cuda.is_available())"
   ```

### Safety Notes

- **Always ensure the robot is in a safe position** before starting
- **Use L2+B to switch to damping mode** if anything goes wrong
- **Test in an open area** first
- **Keep emergency stop accessible**

## File Structure

```
.
├── Dockerfile                    # Docker configuration for Jetson
├── docker-compose.yml           # Docker Compose configuration
├── deploy_on_jetson_jetson.sh  # Deployment script
├── JETSON_DEPLOYMENT.md        # This guide
└── go2_gym_deploy/            # Your RL deployment code
    ├── build/                  # Compiled C++ binaries
    ├── scripts/               # Python deployment scripts
    └── unitree_sdk2_bin/     # Unitree SDK2 integration
```

## Performance Notes

- The Jetson Orin provides sufficient compute for real-time RL inference
- CUDA acceleration is automatically enabled
- Network latency is minimized by using host networking
- The container runs with privileged access for hardware control

## Next Steps

1. Test the deployment in a safe environment
2. Fine-tune policy parameters if needed
3. Consider implementing additional safety features
4. Monitor system performance during operation

For more information about the original project, see the main README.md file. 