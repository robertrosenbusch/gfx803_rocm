# Dockerized ROCm 6.3.4 to use fancy AI Stuff on Ollama/WhisperX/ComfyUI on [GFX803/Polaris/RX5x0]

This repo provides some docker main buildfiles based on the original published/sponsored AMD ROCm-PyTorch-Dockerimage to (re)compile PyTorch, Torchvision/Torchaudio, ROCBlas and CTranslate2 for the [AMD RX570/RX580/RX590](https://en.wikipedia.org/wiki/Radeon_500_series) to:
1. use [PyTorch](https://github.com/pytorch/pytorch) on gfx803
2. generate AI Pics on [ComfyUI](https://github.com/comfyanonymous/ComfyUI) on gfx803
3. use [WhisperX](https://github.com/m-bain/whisperX) to fast automatic speech recognition on gfx803
4. and use [Ollama](https://github.com/ollama/ollama) for LLVMs on gfx803

into a Docker based on the same AMD-ROCm Stack. 

# Quick links
- **General** [hints on GFX803 and about Motivations](#motivation). You should read it. it could save lifetime.
- **DockerBase** GFX803|[Docker-Components](#rocm-634-used-docker-components-for-baseimage) | [Install](#rocm-634-building-dockerbase-for-gfx803-to-do-some-fancy-ai-stuff)
- **Ollama** GFX803 |[Docker-Components](#rocm-630-ollama-and-openwebui-in-a-dockerfile) | [Benchmark](#rocm-630-ollama-v054-benchmark-on-rx570-vs-cpu-ryzen7-3700x) |[Install](#install-ollama-and-open-webui-for-rocm-63)
- **PyTorch** GFX803 |[Docker-Components](#rocm-630-ollama-and-openwebui-in-a-dockerfile)|[Install](#install-rocm-63-pytorch-torchvision-and-torchaudio-via-docker-for-comfyuiwhisperx)
- **ComfyUi** on PyTorch GFX803 | [Docker-Components](#) | [Benchmark](#)| [Install](#)
- **WhsiperX** on PyTorch GFX803 | [Docker-Components](#) | [Install](#)


## Motivation
Ollama, PyTorch, Torchvision/Torchaudio _and_ rocBLAS-Library are not compiled to use the GPU-Polaris generation in the original PIP repository. And of course not compiled too in the official ROCm-PyTorch Dockerfile. However, if Polaris/gfx803 GPU support is to be used in Ollama,ComfyUI or WhisperX on ROCm, there is no way around newly compiled PyTorch and Torchvision/Torchaudio whl/wheel python files. And for Ollama in ROCm 6.X you have to recompile the rocBLAS-Library too. That what this Docker Buildfile(s) will do for you.

> [!IMPORTANT]
> Before you start to build the Specific Container on what AI-App you wanna use for your GFX803-GPU, please check up the next few hints. It could save Lifetime to debug and prevent bad moods or throwing away your gfx803-GPU in a big bow.

> [!NOTE]
> #### At General
> 1. This is an hobby enthusiastic Project into my freetime. gfx803 on ROCm is not supported since [over three years](https://www.techpowerup.com/288864/amd-rocm-4-5-drops-polaris-architecture-support) on any Linux-Distro and was never designed to do some fancy AI-Stuff. So be carefull. Feel free to ask or to make some hints to improve this "project"
> 2. The published Dockercontainers downloaded a lot of stuff and needed a lot of time and storage space to recompile the neccesarry Stuff for gfx803. Big aware, its not my fault.
> 3. Make sure you had have a good ISP-Connection, _*around 50 Gig free Storage and at least one to three hours time to recompile*_, depends what kind of APP you wanna use and your Hardware/ISP.
> 4. Feel free to research/rebuild for ROCm/gfx803 on your Distro-Baremetal-ROCm to use it natively. I am not interessted on, cause i dont wanna maintain any specific Distro-Version. I am sorry.

> [!NOTE]
> #### ROCm hardware requirements
> 1. Make sure, that both Kernel-Devices `/dev/dri` and `/dev/kfd` are aviable 
> 2. Make sure, your Mainboard support [PCIe atomic](https://github.com/ROCm/ROCm/issues/2224#issuecomment-2299689450) for your connected gfx803-GPU(s) `sudo grep flags /sys/class/kfd/kfd/topology/nodes/*/io_links/0/properties` 
> 3. If you wanna use more then one gfx803 aka multiple GPUs [take a look on this](https://github.com/robertrosenbusch/gfx803_rocm/issues/12#issuecomment-2763259884 )

> [!NOTE]
> #### ROCm software requirements
> 1. Make sure your user to start the Dockercontainer is a member of both groups `render`and `video`. 
> 2. it could be possible (depends on your Linux-Distro) to add [a udev-Rule](https://github.com/ROCm/ROCm/issues/1798#issuecomment-1849112550). 
> 4. it is unimportant, which version of ROCm do you use on your Hostsystem
> 3. it is _not_ necessary to install the entire or any ROCm-Stack-Part on the host system. The whole ROCm magic happens inside the Dockercontainer

> [!TIP]
> You should reboot after adding groups to your user and before you start the Dockercontainer.

> [!CAUTION]
> #### Prevent ROCm SegFaults on your Linux Distro
> After some feedback/research from Users who are using the Dockercontainer from this GIT in [Ollama](https://github.com/robertrosenbusch/gfx803_rocm/issues/8#issue-2919996555) and [PyTorch/ComfyUI](https://github.com/robertrosenbusch/gfx803_rocm/issues/13#issuecomment-2754796999), cause the devices `/dev/dri` and  `/dev/kfd` crashed with SegFaults. Please proofe your used Linux-Kernel Version and switch up or down to a well known working Kernel-Version. Fedora 41, Arch and Debian 13 using (in April 2015) suspicious Linux-Kernel-Versions as default. On Kernelversion 6.12 its seems to be fixed on 6.12.
> |Kernel Version|6.14|6.13|6.12|6.11|6.10|6.9|6.6|6.2|5.19|
> |--------------|-----|-----|------|-----|------|-----|-----|-----|-----|
> |working on ROCm 6.3.4 for Ollama/PyTorch|✅|🟥|🟥|✅|✅|✅|✅|✅|✅|
> An user on this GIT-Repo reported he had have success to use a Kernelversion above [6.12.21](https://github.com/robertrosenbusch/gfx803_rocm/issues/8#issuecomment-2820146489)

---
## ROCm-6.3.4: Building Dockerbase for GFX803 to do some fancy AI Stuff
>[!IMPORTANT] 
>To build this Dockerimage is the base for all other fancy AI stuff on GFX803. Its all based on an [official AMD ROCm Docker](https://hub.docker.com/layers/rocm/dev-ubuntu-24.04/6.3.4-complete/images/sha256-76e99e263ef6ce69ba5d32905623c801fff3f85a6108e931820f6eb1d13eac67) 

### ROCm-6.3.4: Used Docker Components for BaseImage 
|OS            |Python|ROCm |GPU|
|--------------|------|-----|-----|
|Ubuntu 24.04|3.12|6.3.4|RX5(x)0 aka Polaris 20/21 aka GCN 4|

### Install
1. Checkout this GIT repo via `git clone https://github.com/robertrosenbusch/gfx803_rocm.git` and change into the directory `gfx803_rocm`
2. Build the GFX803-Base-Docker-Image docker `build -f Dockerfile_rocm634_base . -t 'rocm6_gfx803_ollama:6.3.4`
3. It could take around 30 to 60 minutes to download, recompile and build this _base_ ROCm container

## ROCm-6.3.4 Ollama and OpenWebui in a Dockerfile
* Exposed Ports: 8080,11434
* rocBLAS Library: [6.3.4](https://github.com/ROCm/rocBLAS/releases/tag/rocm-6.4.0)
* Ollama : [v0.6.8](https://github.com/ollama/ollama/releases/tag/v0.6.8)
* OpenWebui-GUI [latest](https://github.com/open-webui/open-webui.git)
* Interactive LLM-Benchmark for Ollama: [latest](https://github.com/willybcode/llm-benchmark.git)

### ROCm-6.3.4: Benchmark Ollama v0.6.(x) on RX570 
Benchmarks moved to [Wiki](https://github.com/robertrosenbusch/gfx803_rocm/wiki/ROCm-6.3.4-Ollama-Benchmarks)

### ROCm-6.3.4: Install Ollama v0.6.(x) and Open-Webui on RX5(x)0
> [!NOTE]
> You should have at least 8 GB of VRAM available to run up to 7B models, and two GFX803 cards to run the 13B models

1. build the DockerBase from this GITRepo for gfx803 first.   
2. Build the Docker Image for Ollama, it takes aroud 60 Minutes: `docker build -f Dockerfile_rocm634_ollama . -t 'rocm634_gfx803_ollama:0.6.8'`
3. Start the container via `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 8080:8080 -p 11434:11434  --name rocm643_ollama_068 rocm634_gfx803_ollama:0.6.8 bash`
3. Enter to the Dockercontainer `docker exec -ti rocm634_ollama_068 bash`
4. [download a model](https://ollama.com/search) you need for e.g. `./ollama run deepseek-r1:1.5b`
6. Open your Webbrowser `http://YOUR_LOCAL_IP:8080` to use Open-WebUI
7. If you wanna use e.g. VSCode or Open-WebUI from outside, the Port 11434 is exposed too.
8. For Benchmark your downloaded Models use `python3 /llm-benchmark/benchmark.py` inside the container

## ROCm-6.3.0 PyTorch,TorchVision and TorchAudio for ComfyUI in a Dockerfile

* Used ROCm Docker Version: [rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0](https://hub.docker.com/layers/rocm/pytorch/rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0/images/sha256-98ddf20333bd01ff749b8092b1190ee369a75d3b8c71c2fac80ffdcb1a98d529?context=explore)     
* PyTorch GIT: [v2.5.1](https://github.com/ROCm/pytorch/tree/release/2.5)
* Torchvison GIT: [v0.20.0](https://github.com/pytorch/vision/releases/tag/v0.20.0)
* TorchAudio GIT: [v2.5.1](https://github.com/pytorch/audio/releases/tag/v2.5.1)
* rocBLAS Library: [6.3.0](https://github.com/ROCm/rocBLAS/releases/tag/rocm-6.3.0)

## Install ROCm 6.3 PyTorch, TorchVision and TorchAudio via Docker for ComfyUI/WhisperX
> [!WARNING]  
> It takes a _lot_ of time and Storage space to compile. Around 100 GByte Storage and 3 hours to (re-)compile. Keep your head up. Its worth!

1. build your Docker image via `docker build -f  Dockerfile_rocm63_pt25 . -t 'rocm63_pt25:latest'`
2. start the container via: `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 8188:8188 -v /YOUR/LOCAL/COMFYUI/CHECKPOINTS:/comfy/ --name rocm63_pt25 rocm63_pt25:latest bash`
3. After installing ComfyUI _reinstall_ pytorch, torchvision and torchaudio wheels into your ComfyUI-Python-Environment. You will find the GFX803/Polaris compiled Python-Wheel-Files into the `/pytorch/dist`, `/vision/dist` and `/audio/dist` Directory.
 *OR* use [my ComfyUI-Container-Dockerfile](https://github.com/robertrosenbusch/gfx803_rocm/blob/main/Dockerfile_rocm63_comfyui) | [WhisperX-Container-Dockerfile](#)


OpenWebui
> [!NOTE]
> 1. Since ROCm 6.0 you have to use the _`--lowvram`_ option at ComfyUI's main.py to create correct results. *Dont know why* ...
> 2. Since PyTorch 2.4 you have to use the _`MIOPEN_LOG_LEVEL=3`_ Environment-Var to surpress HipBlas-Warnings. *Dont know why* ...


### ROCm-6.3.0 ComfyUI Benchmark on RX570/RX590
|       |SD 1.5  (512x512)|SD 1.5  (512x768)|SDXL  (1024x1024)|SD3.5  (1024x1024)|Flux -Schnell (1024x1024)|
|--------------|-----|------|-----|-----|-----|
|ROCm 6.3 + PyTorch v2.5 (RX570)|[1.19 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd15_512x512_sd.png)|[1.92 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd15_512x768_sd.png)|[7.57 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sdxl_1024x1024l.png)|[19.56 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd35_1024x1024.png)|[63.72 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_schnell_1024x1024.png)|
|ROCm 6.3 + PyTorch v2.5 (RX590)|1.06 s/it|1.48 s/it|6.22 s/it|n.a.|n.a.|
|ROCm 5.7 + PyTorch v2.3 (RX570)|1.22 s/it|1.97 s/it|8.33 s/it|19.87 s/it|58.85 s/it|





