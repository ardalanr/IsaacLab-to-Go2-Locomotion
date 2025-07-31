# PC Testing Guide for Go2 RL Deployment

This guide explains how to test the Docker container on your PC before deploying to the Jetson Orin.

## Overview

Testing on PC helps verify that:
- All dependencies are correctly installed
- The build process works
- Python packages are compatible
- C++ components compile successfully
- The container environment is properly configured

## Prerequisites

### On Your PC:

1. **Install Docker**:
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install docker.io
   sudo usermod -aG docker $USER
   # Log out and back in
   
   # Or use Docker's official installation script
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```

2. **Verify Docker Installation**:
   ```bash
   docker --version
   docker run hello-world
   ```

## Testing Steps

### 1. Run the Test Script

```bash
chmod +x test_on_pc.sh
./test_on_pc.sh
```

The script will:
- Check your Docker environment
- Build the container using `Dockerfile.pc`
- Offer three testing options

### 2. Choose a Test Option

#### Option 1: Quick Build Test
- Verifies container starts successfully
- Checks Python 3.8 installation
- Tests PyTorch and LCM imports
- Fastest option for basic validation

#### Option 2: Full Dependency Test
- Tests all Python packages
- Verifies project installation
- Checks C++ binary compilation
- Validates LCM message files
- Most comprehensive test

#### Option 3: Interactive Test
- Opens an interactive shell in the container
- Allows manual testing and exploration
- Good for debugging specific issues

### 3. Expected Test Results

#### Successful Quick Test Output:
```
Python version: 3.8.x
PyTorch version: 1.10.1
CUDA available: True/False (depends on your GPU)
LCM import successful
✅ Quick test passed!
```

#### Successful Full Test Output:
```
Testing Python environment...
Python 3.8.x
PyTorch 1.10.1
NumPy 1.23.5
LCM import successful

Testing project installation...
go2_gym import successful

Testing C++ binaries...
[list of compiled binaries]

Testing LCM message generation...
[list of .lcm files]

✅ Full dependency test completed!
```

## Troubleshooting

### Common Issues

1. **Docker Permission Denied**:
   ```bash
   sudo usermod -aG docker $USER
   # Log out and back in
   ```

2. **Build Fails**:
   - Check internet connection
   - Ensure sufficient disk space
   - Verify Docker has enough memory allocated

3. **Python Import Errors**:
   - Container may need to be rebuilt
   - Check if all dependencies are installed

4. **C++ Compilation Errors**:
   - Verify build tools are installed
   - Check if all system dependencies are present

### Debugging Tips

1. **Check Container Logs**:
   ```bash
   docker logs <container_id>
   ```

2. **Inspect Container**:
   ```bash
   docker run -it go2-rl-deploy-test bash
   ```

3. **Test Individual Components**:
   ```bash
   # Test Python
   docker run --rm go2-rl-deploy-test python3 -c "import torch; print(torch.__version__)"
   
   # Test LCM
   docker run --rm go2-rl-deploy-test python3 -c "import lcm; print('LCM OK')"
   ```

## File Structure

```
.
├── Dockerfile              # Jetson-specific Dockerfile
├── Dockerfile.pc          # PC testing Dockerfile
├── test_on_pc.sh         # PC testing script
├── PC_TESTING.md         # This guide
├── deploy_on_jetson_jetson.sh  # Jetson deployment script
└── JETSON_DEPLOYMENT.md  # Jetson deployment guide
```

## Next Steps

After successful PC testing:

1. **Copy files to Jetson**:
   - `Dockerfile` (not Dockerfile.pc)
   - `docker-compose.yml`
   - `deploy_on_jetson_jetson.sh`
   - `JETSON_DEPLOYMENT.md`

2. **Deploy on Jetson**:
   ```bash
   ./deploy_on_jetson_jetson.sh
   ```

3. **Follow Jetson deployment guide**:
   - See `JETSON_DEPLOYMENT.md`

## Performance Notes

- PC testing uses Ubuntu 22.04 base image
- Jetson deployment uses NVIDIA L4T 35.3.1 base image
- Both use the same Python 3.8 and dependency versions
- PC testing may be faster due to x86 architecture
- Jetson deployment includes ARM-specific optimizations

## Safety Notes

- PC testing is safe and doesn't interact with the robot
- No network communication with Go2 during testing
- Container is isolated from host system
- All tests are non-destructive

For more information about the original project, see the main README.md file. 