# ROCm 6.3.0, PyTorch 2.5, Torchvision 0.20 with AMD GFX803 aka AMD Polaris aka AMD RX570/RX580/RX590 for ComfyUI or Ollama

This repo provides a docker main buildfile based on the original ROCm-Dockerimage to compile PyTorch and Torchvision for the [AMD RX570/RX580/RX590](https://en.wikipedia.org/wiki/Radeon_500_series) generation to generate AI Pics on ComfyUI. And a Dockerfile to build Ollama on the same ROCm Stack. PyTorch, Torchvision _and_ rocBLAS-Library are not compiled to use the GPU-Polaris generation in the original PIP repository. And of course not compiled too in the official ROCm-PyTorch Dockerfile. However, if Polaris 20/21 GPU support is to be used in ComfyUI, there is no way around newly compiled PyTorch and Torchvision whl/wheel python files. And for Ollama in ROCm 6.X you have to recompile the rocBLAS-Library too. That what this Docker Buildfile(s) will do for you.

## ROCm-6.3.0 PyTorch for ComfyUI in a Dockerfile

|OS            |linux|Python|ROCm |PyTorch|Torchvision|GPU|
|--------------|-----|------|-----|-----|-----|-----|
|Ubuntu-24.04|6.X and 5.19 |3.12|6.3.0|2.5.1|0.20.0|RX570/580/590 aka Polaris 20/21 aka GCN 4|

* Used ROCm Docker Version: [rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0](https://hub.docker.com/layers/rocm/pytorch/rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0/images/sha256-98ddf20333bd01ff749b8092b1190ee369a75d3b8c71c2fac80ffdcb1a98d529?context=explore)     
* PyTorch GIT: [v2.5.1](https://github.com/ROCm/pytorch/tree/release/2.5)
* Torchvison GIT: [v0.20.0](https://github.com/pytorch/vision/releases/tag/v0.20.0)
* rocBLAS Library: [6.3.0](https://github.com/ROCm/rocBLAS/releases/tag/rocm-6.3.0)

##### ROCm-6.3.0 ComfyUI Benchmark on RX570
|CPU/GPU       |Flux -Schnell (1024x1024)|SD3.5  (1024x1024)|SDXL  (1024x1024)|SD 1.5  (512x512)|SD 1.5  (512x768)|
|--------------|-----|------|-----|-----|-----|
|ROCm 6.3 + PyTorch v2.5|[63.72 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_schnell_1024x1024.png)|[19.56 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd35_1024x1024.png)|[7.57 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sdxl_1024x1024l.png)| [1.19 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd15_512x512_sd.png)|[1.92 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd15_512x768_sd.png)|
|ROCm 5.7 + PyTorch v2.3|58.85 s/it|19.87 s/it|8.33 s/it|1.22 s/it|1.97 s/it|


## ROCm-6.3.0 Ollama / Webopen-webui in a Dockerfile

|OS            |linux|Python|ROCm |Ollama|GPU|Mapping Port|
|--------------|-----|------|-----|------|-----|-----|
|Ubuntu-24.04|6.X and 5.19 |3.12|6.3.0|v0.5.4|RX570/580/590 aka Polaris 20/21 aka GCN 4|8080|
* Used ROCm Docker Version: [rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0](https://hub.docker.com/layers/rocm/pytorch/rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0/images/sha256-98ddf20333bd01ff749b8092b1190ee369a75d3b8c71c2fac80ffdcb1a98d529?context=explore)     
* rocBLAS Library: [6.3.0](https://github.com/ROCm/rocBLAS/releases/tag/rocm-6.3.0)
* Ollama for AMD: [v0.5.4](https://github.com/likelovewant/ollama-for-amd/releases/tag/v0.5.4)
* Interactive LLM-Benchmark for Ollama: [latest](https://github.com/willybcode/llm-benchmark.git)

##### ROCm-6.3.0 Ollama v0.5.4 Benchmark on RX570 vs CPU Ryzen7 3700x
|CPU/GPU       |deepseek-r1:8b|llama3.1:8b|llama2:7b|
|--------------|-----|------|-----|
|[GPU AMD RX570](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/gpu_rocm63_ollama_benchmark.png)|Total: 18.19 t/s|Total: 18.80 t/s|Total: 27.46 t/s|
|[CPU AMD Ryzen 7 3700x](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/cpu_rocm63_ollama_benchmark.png)| Total: 7.33 t/s|Total: 7.53 t/s|Total: 8.76 t/s|

![GFX803_rocm63_ollama_benchmark](https://github.com/robertrosenbusch/gfx803_rocm/blob/b3db63e7824effa281a5a386d8e1b4dd252aec94/benchmark/gfx803_rocm63_ollama_benchmark.png?raw=true)


--
# Install ROCm 6.3 PyTorch and TorchVision via Docker for ComfyUI
- It is _not_ necessary to install the entire ROCm-Stack on the host system. _Unless_ you want to use something to optimize your GPU via rocm-smi. In my case, I need the rocm stuff to reduce the power consumption of my RX570 GPU to 145 watts with `rocm-smi --setpoweroverdrive 145 && watch -n2 rocm-smi` every time I restart the container.
- It takes a _lot_ of time to compile

1. install the docker-subsystem / docker.io on your linux system
2. download the latest file version of this github-repos vi git clone
4. build your Docker image via `docker build . -t 'rocm63_pt25:latest'`
5. start the container via: `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 8188:8188 -v /YOUR/LOCAL/COMFYUI/CHECKPOINTS:/comfy/ --name rocm63_pt25 rocm63_pt25:latest bash`
6. install ComfyUI and download a Model inside the container (/comfyui) _OR_ use [my ComfyUI-Container-Dockerfile](https://github.com/robertrosenbusch/gfx803_rocm/blob/main/Dockerfile_rocm63_comfyui)
7. After installing ComfyUI _reinstall_ pytorch and torchvision wheels into your ComfyUI-Python-Environment. You will find the Polaris compiled Python-Wheel-Files into the `/pytorch/dist` and `/vision/dist` Directory.
8. Since ROCm 6.0 you have to use the _`--lowvram`_ option at ComfyUI's main.py to create correct results. *Dont know why* ...
9. Since PyTorch 2.4 you have to use the _`MIOPEN_LOG_LEVEL=3`_ Environment-Var to surpress HipBlas-Warnings. *Dont know why* ...



# Install Ollama and Open-Webui for ROCm 6.3

1. install the docker-subsystem / docker.io on your linux system
2. download the latest file version of this github-repos vi git clone
3. build your Docker image via `docker build -f Dockerfile_rocm63_ollama . -t 'rocm63_ollama:latest'`
4. start the container via: `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 8080:8080 -p 11434:11434 --name rocm63_ollama rocm63_ollama:latest bash`
5. Start `./ollama serve&` into background and [download a model](https://ollama.com/search) you need for e.g. `./ollama run deepseek-r1:1.5b`
6. Start Open-WebUI `open-webui serve &` 
7. For Benchmark your downloaded Models use `python /llm-benchmark/benchmark.py`