# ROCm 6.3.0 , PyTorch 2.4, Torchvision 0.19 with AMD GFX803 aka AMD Polaris aka AMD RX570/RX580/RX590 for ComfyUI

This repo provides a docker buildfile based on the original ROCm-Dockerimage to compile PyTorch and Torchvision for the [AMD RX570/RX580/RX590](https://en.wikipedia.org/wiki/Radeon_500_series) generation to generate AI Pics on ComfyUI. PyTorch, Torchvision _and_ rocBLAS-Library are not compiled to use the GPU-Polaris generation in the original PIP repository. And of course not compiled too in the official ROCm-PyTorch Dockerfile. However, if Polaris 20/21 GPU support is to be used in ComfyUI, there is no way around newly compiled PyTorch and Torchvision whl/wheel python files. And in ROCm 6.X you have to recompile rocBLAS-Library too. That what this Docker Buildfile will do for you.

## ROCm-6.3.0 in a Dockerfile

|OS            |linux|Python|ROCm |PyTorch|Torchvision|GPU|
|--------------|-----|------|-----|-----|-----|-----|
|Ubuntu-24.04|6.X and 5.19 |3.12|6.3.0|2.4.0|0.19.0|RX570/580/590 aka Polaris 20/21 aka GCN 4|

## BIG BEWARE. The included WHL-Files on this github-repo are compiled, tested and uploaded for GFX803 into this Dockerfile-Image i published!!! 

* Used ROCm Docker Version: [rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0](https://hub.docker.com/layers/rocm/pytorch/rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0/images/sha256-98ddf20333bd01ff749b8092b1190ee369a75d3b8c71c2fac80ffdcb1a98d529?context=explore)     

* PyTorch GIT: [v2.4.0](https://github.com/pytorch/pytorch/releases/tag/v2.4.0)
* Torchvison GIT: [v0.19.0](https://github.com/pytorch/vision/releases/tag/0.19.0)
* rocBLAS Library: [6.3.0](https://github.com/ROCm/rocBLAS/releases/tag/rocm-6.3.0)

- It is _not_ necessary to install the entire ROCm-Stack on the host system. _Unless_ you want to use something to optimize your GPU via rocm-smi. In my case, I need the rocm stuff to reduce the power consumption of my RX570 GPU to 145 watts with `rocm-smi --setpoweroverdrive 145 && watch -n2 rocm-smi` every time I restart the container.

1. install the docker-subsystem / docker.io on your linux system
2. download the latest file version of this github-repos
3. if you trust my compiled WHL-Files into this git-repo, just comment out from Line #76 to Line #116 and import the whl-Files into the container after the building process
4. build your Docker image via `docker build . -t 'rocm63_pt24:latest'`
5. start the container via: `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined  -p 8188:8188 rocm63_pt24:latest`
6. install ComfyUI and download a Model inside the container _OR_ use [my ComfyUI-Container-Dockerfile](https://github.com/robertrosenbusch/gfx803_rocm_comfyui)
7. After installing ComfyUI _reinstall_ pytorch and torchvision wheels into your ComfyUI-Python-Environment. You will find the Polaris compiled Python-Wheel-Files into the "/pytorch/dist" and "/vision/dist" Directory or if you use the precompiled WHL file from this repo into the directory you are mapped and transfered.
8. Since ROCm 6.0 you have to use the _"--lowvram"_ option at ComfyUI's main.py to create correct results. *Dont know why* ...
