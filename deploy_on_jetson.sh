#!/bin/bash

# Script to deploy Go2 RL policy on Jetson Orin using Docker
# This script handles building and running the Docker container

set -e

echo "=== Go2 RL Deployment on Jetson Orin ==="
echo "Building Docker container..."

# Build the Docker image
docker build -t go2-rl-deploy .

echo "Docker image built successfully!"
echo ""
echo "=== Usage Instructions ==="
echo ""
echo "1. To run the container interactively:"
echo "   docker run -it --privileged --network host --gpus all go2-rl-deploy"
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
echo "=== Important Notes ==="
echo "- Make sure the robot is connected via ethernet"
echo "- Verify network interface (eth0 or similar)"
echo "- Ensure robot is in a safe position before starting"
echo "- Use L2+B to switch to damping mode if needed"
echo ""
echo "Container is ready for deployment!" 