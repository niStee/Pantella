#!/bin/bash

if conda info --envs | grep -q pantella-env; then 
    echo "pantella-env already exists";
else 
    conda create -y -n pantella-env python=3.10; 
fi
source ~/miniconda3/etc/profile.d/conda.sh
echo "Activating pantella-env"
conda activate pantella-env
echo "Installing dependencies"
python3 -m pip install -r requirements.txt
read -p "Do you want to install torch with CUDA support? (y/n): " install_torch
if [[ "$install_torch" == "y" || "$install_torch" == "Y" ]]; then
    python3 -m  pip install -r cuda_torch_requirements.txt --no-deps --force-reinstall --upgrade
fi
# Ask user if they want to install llama-cpp-python with CUDA or not
read -p "Do you want to install llama-cpp-python with CUDA support? (y/n): " install_cuda
if [[ "$install_cuda" == "y" || "$install_cuda" == "Y" ]]; then
    CMAKE_ARGS="-DGGML_CUDA=on"
    python3 -m pip install "llama-cpp-python @ git+https://github.com/JamePeng/llama-cpp-python.git" --no-deps --force-reinstall --upgrade --no-cache-dir --upgrade
fi