#!/bin/bash

# Script to deploy Go2 RL policy on Jetson Orin using Docker
# This script handles building and running the Docker container on Jetson

set -e

echo "=== Go2 RL Deployment on Jetson Orin ==="
echo "Checking Jetson environment..."

# Check if we're on a Jetson device
if [ ! -f /etc/nv_tegra_release ]; then
    echo "Warning: This script is designed for Jetson devices"
    echo "Make sure you're running this on a Jetson Orin"
fi

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "Docker installed. Please log out and back in, then run this script again."
    exit 1
fi

# Check NVIDIA Container Toolkit
if ! docker run --rm --gpus all nvidia/cuda:11.6-base-ubuntu20.04 nvidia-smi &> /dev/null; then
    echo "NVIDIA Container Toolkit not properly configured."
    echo "Please install it: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
    exit 1
fi

echo "Building Docker container for Jetson..."

# Build the Docker image
docker build -t go2-rl-deploy-jetson .

echo "Docker image built successfully!"
echo ""
echo "=== Usage Instructions ==="
echo ""
echo "1. To run the container interactively:"
echo "   docker run -it --privileged --network host --gpus all go2-rl-deploy-jetson"
echo ""
echo "2. Or use docker-compose:"
echo "   docker-compose up -d"
echo "   docker-compose exec go2-rl-deploy bash"
echo ""
echo "3. Inside the container, you can:"
echo "   - Test LCM communication:"
echo "     cd go2_gym_deploy/build"
echo "     sudo ./lcm_receive"
echo ""
echo "   - Start LCM position control:"
echo "     cd go2_gym_deploy/build"
echo "     sudo ./lcm_position_go2 eth0"
echo ""
echo "   - Deploy the policy:"
echo "     cd go2_gym_deploy/scripts"
echo "     python3 deploy_policy.py"
echo ""
echo "=== Jetson-Specific Notes ==="
echo "- Using L4T 35.3.1 base image for optimal compatibility"
echo "- Python 3.8 as required by the project"
echo "- Following README deployment instructions exactly"
echo "- PyTorch 1.10 with CUDA 11.3 as specified in README"
echo "- Unitree SDK2 and LCM installed from source"
echo "- Network interface might be different (check with 'ip addr')"
echo "- Make sure the robot is connected via ethernet"
echo "- Ensure robot is in a safe position before starting"
echo "- Use L2+B to switch to damping mode if needed"
echo ""
echo "Container is ready for deployment on Jetson!" 