#!/bin/bash

# ====================================================
# Install CUDA
# In this script, you need to replace the placeholders
# <driver_package>, <cuda_version>, <cudnn_version>, \
# <miniconda_installer_url>, <pytorch_version>
# with the appropriate values for your setup.
# ====================================================

# Install GPU Drivers
# Replace <driver_package> with the appropriate driver package for your GPU
sudo apt update
sudo apt install -y <driver_package>

# Install CUDA Toolkit
# Replace <cuda_version> with the desired CUDA version (e.g., 11.1, 10.2)
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-<cuda_version>_1.0.0-1_amd64.deb
sudo dpkg -i cuda-<cuda_version>_1.0.0-1_amd64.deb
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
sudo apt update
sudo apt install -y cuda

# Install cuDNN
# Replace <cudnn_version> with the desired cuDNN version (e.g., 8.2.4)
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/libcudnn8_<cudnn_version>.+cuda<cuda_version>_amd64.deb
sudo dpkg -i libcudnn8_<cudnn_version>.+cuda<cuda_version>_amd64.deb
sudo apt update
sudo apt install -y libcudnn8

# Install Miniconda or Anaconda
# Replace <miniconda_installer_url> with the URL of the Miniconda installer script
wget <miniconda_installer_url> -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
rm miniconda.sh

# Add Conda to PATH (optional, remove if not needed)
echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.bashrc
source $HOME/.bashrc

# Create and Activate Conda Environment
conda create -n myenv python=3.9
conda activate myenv

# Install PyTorch
# Replace <pytorch_version> with the desired PyTorch version
conda install pytorch==<pytorch_version> torchvision torchaudio cudatoolkit=<cuda_version> -c pytorch

# Verify Installation
python -c "import torch; print('PyTorch version:', torch.__version__)"
python -c "if torch.cuda.is_available(): print('GPU available:', torch.cuda.get_device_name(0))"
