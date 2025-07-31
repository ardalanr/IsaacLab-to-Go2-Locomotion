#!/bin/bash

# Script to test Go2 RL deployment Docker container on PC
# This script helps verify the container works before deploying to Jetson

set -e

echo "=== Go2 RL Docker Container Test on PC ==="
echo "This script will test the container on your PC before Jetson deployment"
echo ""

# Check if we're on a Linux system
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Warning: This script is designed for Linux systems"
    echo "Docker testing on other OS may have limitations"
fi

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo "Error: Docker not found. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running."
    echo "Please start Docker and try again."
    exit 1
fi

echo "Docker environment check passed!"
echo ""

# Build the Docker image for testing
echo "Building Docker container for PC testing..."
docker build -f Dockerfile.pc -t go2-rl-deploy-test .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully!"
else
    echo "❌ Docker build failed!"
    exit 1
fi

echo ""
echo "=== Container Test Options ==="
echo "1. Quick build test (verify container starts)"
echo "2. Full dependency test (check all components)"
echo "3. Interactive test (enter container and test manually)"
echo ""

read -p "Choose test option (1-3): " test_option

case $test_option in
    1)
        echo "Running quick build test..."
        docker run --rm go2-rl-deploy-test python3 -c "
import sys
print(f'Python version: {sys.version}')
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
import lcm
print('LCM import successful')
print('✅ Quick test passed!')
"
        ;;
    2)
        echo "Running full dependency test..."
        docker run --rm go2-rl-deploy-test bash -c "
echo 'Testing Python environment...'
python3 -c 'import sys; print(f\"Python {sys.version}\")'
python3 -c 'import torch; print(f\"PyTorch {torch.__version__}\")'
python3 -c 'import numpy; print(f\"NumPy {numpy.__version__}\")'
python3 -c 'import lcm; print(\"LCM import successful\")'

echo 'Testing project installation...'
cd /workspace
python3 -c 'import go2_gym; print(\"go2_gym import successful\")'

echo 'Testing C++ binaries...'
cd /workspace/go2_gym_deploy/build
ls -la

echo 'Testing LCM message generation...'
cd /workspace/go2_gym_deploy/lcm_types
ls -la *.lcm

echo '✅ Full dependency test completed!'
"
        ;;
    3)
        echo "Starting interactive test..."
        echo "You can now test the container manually."
        echo "Type 'exit' to leave the container."
        echo ""
        docker run -it --rm go2-rl-deploy-test bash
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

echo ""
echo "=== Test Results ==="
echo "If all tests passed, the container should work on Jetson."
echo ""
echo "=== Next Steps ==="
echo "1. Copy the Dockerfile and related files to your Jetson"
echo "2. Run: ./deploy_on_jetson_jetson.sh"
echo "3. Follow the Jetson deployment guide"
echo ""
echo "=== Files to Copy to Jetson ==="
echo "- Dockerfile"
echo "- docker-compose.yml"
echo "- deploy_on_jetson_jetson.sh"
echo "- JETSON_DEPLOYMENT.md"
echo ""
echo "Test completed!" 