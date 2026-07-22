#!/bin/bash

if conda info --envs | grep -q pantella-env; then 
    echo "pantella-env already exists, if you have problems, please delete the pantella-env and run this script again";
else 
    echo "Installing Pantella..."
    ./linux_install.sh
fi
source ~/miniconda3/etc/profile.d/conda.sh
echo "Activating pantella-env"
conda activate pantella-env
python main.py