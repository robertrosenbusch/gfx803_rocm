# Dockerized ROCm 6.4.0 to use fancy AI Stuff on Ollama/WhisperX/ComfyUI on [GFX803/Polaris/RX5x0]

This repo provides some docker main buildfiles based on the original published/sponsored AMD ROCm-DEV-Dockerimage to (re)compile PyTorch, Torchvision/Torchaudio, ROCBlas and CTranslate2 for the [AMD RX570/RX580/RX590](https://en.wikipedia.org/wiki/Radeon_500_series) to:
1. use [PyTorch](https://github.com/pytorch/pytorch) on gfx803
2. generate AI Pics on [ComfyUI](https://github.com/comfyanonymous/ComfyUI) on gfx803
3. use [WhisperX](https://github.com/m-bain/whisperX) to fast automatic speech recognition and transcription on gfx803
4. and use [Ollama](https://github.com/ollama/ollama) for LLVMs on gfx803

into a Docker based on the same AMD-ROCm Stack. 

# Quick links
- **General** [hints on GFX803 and about Motivations](#motivation). You should read it. it could save lifetime.
- **DockerBase** GFX803|[Docker-Components](#rocm-640-used-docker-components-for-baseimage-on-rx5x0gfx803) | [Install](#rocm-640-buildinstall-baseimage-for-gfx803-to-do-some-fancy-ai-stuff)
- **Ollama** GFX803 |[Docker-Components](#rocm-640-used-docker-components-for-ollama-v06x-and-openwebui-on-rx5x0gfx803) | [Install](#rocm-640-buildinstall-ollama-v07x-and-open-webui-on-rx5x0gfx803)|[Benchmark](#rocm-640-benchmark-ollama-v06x-v07x-on-rx570) |
- **ComfyUi** on PyTorch GFX803 | [Docker-Components](#rocm-634-used-docker-components-for-comfyui) | [Install](#rocm-634-buildinstall-comfyui-on-rx5x0gfx803)|[Benchmark](#rocm-630-comfyui-benchmark-on-rx570rx590)|
- **PyTorch** GFX803 |[Docker-Components](#rocm-634-used-docker-components-for-pytorchtorchvision-and-torchaudio-on-rx5x0gfx803)|[Install](#rocm-634-buildinstall-pytorch-torchvision-and-torchaudio-on-rx5x0gfx803)
- **WhsiperX** on PyTorch GFX803 | [Docker-Components](#rocm-640-used-docker-components-for-whisperx) | [Install](#rocm-640-buildinstall-whisperx-on-rx5x0gfx803)


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
> |Kernel Version|>=6.15.8|6.14|6.13|>=6.12.21|6.11|6.10|6.9|6.8|6.6|6.2|5.19|
> |--------------|-----|-----|-----|------|-----|------|-----|-----|-----|-----|-----|
> |working on ROCm6.4.(x) for Ollama/PyTorch/WhisperX|✅|🟥|🟥|✅|✅|✅|✅|✅|✅|✅|✅|
 Beware(!) the AMD-ROCm Team just only official support [these Kernel-Versions!](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html#supported-operating-systems)

---
## ROCm-6.4.0: Docker Baseimage for RX5(x)0/GFX803
>[!IMPORTANT] 
>Build this Docker Baseimage for all other fancy AI stuff on GFX803. Its all based on an [official AMD ROCm Docker](https://hub.docker.com/layers/rocm/dev-ubuntu-24.04/6.4-complete/images/sha256-9fbf729ab0d20e7f198be388bd81abcd9f63f1092119086dd4bb4d971b4318d4) 

> [!NOTE]
> It could take around 30 to 60 minutes to download, recompile and build this _base_ ROCm container Image, depends on your Hardware and your ISP

### ROCm-6.4.0: Used Docker Components for Baseimage on RX5(x)0/GFX803
|OS            |ROCm |rocBLAS|Python|GPU|
|--------------|------|------|-----|-----|
|Ubuntu 24.04|6.4.0|6.4.0|3.12|RX5(x)0 aka Polaris 20/21 aka GCN 4|

### ROCm-6.4.0: Build/Install Baseimage for GFX803 to do some fancy AI Stuff
1. Checkout this GIT repo via `git clone https://github.com/robertrosenbusch/gfx803_rocm.git` and change into the directory `gfx803_rocm`
2. Build the GFX803-Base-Docker-Image `docker build -f Dockerfile_rocm64_base . -t 'rocm6_gfx803_base:6.4'`

---
## Ollama

### ROCm-6.4.0: Used Docker Components for Ollama v0.9.(x) and OpenWebui on RX5(x)0/GFX803
* Exposed Ports: 8080,11434
* Ollama : [v0.9.0](https://github.com/ollama/ollama/releases/tag/v0.9.0)
* OpenWebui-GUI [latest](https://github.com/open-webui/open-webui.git)
* Interactive LLM-Benchmark for Ollama: [latest](https://github.com/willybcode/llm-benchmark.git)

### ROCm-6.4.0: Build/Install Ollama v0.9.(x) and Open-Webui on RX5(x)0/GFX803
> [!NOTE]
> You should have at least 8 GB of VRAM available to run up to 7B models, and two GFX803 cards to run the 13B models

0. build the Docker Baseimage from this GITRepo for gfx803 first.  
1. Build the Docker Image for Ollama, it takes aroud 60 Minutes: `docker build -f Dockerfile_rocm64_ollama . -t 'rocm64_gfx803_ollama:0.9.0'`
2. Start the container via `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 8080:8080 -p 11434:11434  --name rocm64_ollama_090 rocm64_gfx803_ollama:0.9.0 bash`
3. Enter to the Dockercontainer `docker exec -ti rocm64_ollama_090 bash`
4. [download a model](https://ollama.com/search) you need for e.g. `./ollama run deepseek-r1:1.5b`
5. Open your Webbrowser `http://YOUR_LOCAL_IP:8080` to use Open-WebUI
6. If you wanna use e.g. VSCode or Open-WebUI from outside, the Port 11434 is exposed too.
7. For Benchmark your downloaded Models use `python3 /llm-benchmark/benchmark.py` inside the container

### ROCm-6.4.0: Benchmark Ollama v0.6.(x)/ v0.7.(x)/v0.8.(x)/v0.9.(x) on RX570 
Benchmarks for Ollama moved to [Wiki](https://github.com/robertrosenbusch/gfx803_rocm/wiki/ROCm-6.4.0-Ollama-Benchmarks)

---
## ComfyUI

### ROCm-6.4.0: Used Docker Components for ComfyUI
* Exposed ComfyUI GUI Port: 8188
* PyTorch GIT: [v2.6.0](https://github.com/ROCm/pytorch/tree/release/2.6)
* Torchvison GIT: [v0.21.0](https://github.com/pytorch/vision/releases/tag/v0.21.0)
* TorchAudio GIT: [v2.6.0](https://github.com/pytorch/audio/releases/tag/v2.6.0)
* ComfyUI GIT: [latest](https://github.com/comfyanonymous/ComfyUI.git)
* ComfyUI Manager: [latest](https://github.com/ltdrdata/ComfyUI-Manager.git)


### ROCm-6.4.0: Build/Install ComfyUI on RX5(x)0/GFX803
> [!WARNING]  
> It takes a _lot_ of time and Storage space to compile. Around 50 GByte Storage and 2.5 hours to (re-)compile. Keep your head up. Its worth!

> [!NOTE]
> 1. Since ROCm 6.0 you have to use the _`--lowvram`_ option at ComfyUI's main.py to create correct results. *Dont know why* ...
> 2. Since PyTorch 2.4 you have to use the _`MIOPEN_LOG_LEVEL=3`_ Environment-Var to surpress HipBlas-Warnings. *Dont know why* ...

0. build the Docker Baseimage from this GITRepo for gfx803 first. 
1. build your Docker image via `docker build -f Dockerfile_rocm64_comfyui . -t 'rocm64_gfx803_comfyui:latest'`
2. start the container via: `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 8188:8188 -v /YOUR_LOCAL_COMFYUI_MODELS/:/comfy/ --name rocm64_comfyui rocm64_gfx803_comfyui:latest /bin/bash`
4. Open your Webbrowser `http://YOUR_LOCAL_IP:11434` to use ComfyUI
5. Enter to the Dockercontainer `docker exec -ti rocm64_gfx803_comfyui:latest bash` and Download your Modelstuff or SymLink it from `/comfy` 
6. You will find the GFX803/Polaris compiled Python-Wheel-Files inside into the `/pytorch/dist`, `/vision/dist` and `/audio/dist` Directory.


### ROCm-6.3.0 ComfyUI Benchmark on RX570/RX590
Benchmarks for ComfyUI moved to [Wiki](https://github.com/robertrosenbusch/gfx803_rocm/wiki/Benchmark-ComfyUI:-ROCm-6.3.0)

---
## PyTorch

### ROCm-6.4.0: Used Docker Components for PyTorch,TorchVision and TorchAudio on RX5(x)0/GFX803
* PyTorch GIT: [v2.6.0](https://github.com/ROCm/pytorch/tree/release/2.6)
* Torchvison GIT: [v0.21.0](https://github.com/pytorch/vision/releases/tag/v0.21.0)
* TorchAudio GIT: [v2.6.0](https://github.com/pytorch/audio/releases/tag/v2.6.0)

### ROCm-6.4.0: Build/Install PyTorch, TorchVision and TorchAudio on RX5(x)0/GFX803
> [!WARNING]  
> It takes a _lot_ of time and Storage space to compile. Around 40 GByte Storage and 2 hours to (re-)compile. Keep your head up. Its worth!

0. build the Docker Baseimage from this GITRepo for gfx803 first. 
1. build your Docker image via `docker build -f Dockerfile_rocm64_pytorch . -t 'rocm64_gfx803_pytorch:2.6'` 
2. start the container via: `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --name rocm64_pytorch_26 rocm64_gfx803_pytorch:2.6 bash`
3. to confirm your gfx803 working right use [a script like this one](https://github.com/robertrosenbusch/gfx803_rocm/issues/13#issuecomment-2755478167).

---
## WhisperX

### ROCm-6.4.0: Used Docker Components for WhisperX
* Exposed WhisperX GUI Port: 7860
* PyTorch GIT: [v2.6.0](https://github.com/ROCm/pytorch/tree/release/2.6)
* Torchvison GIT: [v0.21.0](https://github.com/pytorch/vision/releases/tag/v0.21.0)
* TorchAudio GIT: [v2.6.0](https://github.com/pytorch/audio/releases/tag/v2.6.0)
* CTranslate for ROCm: [latest](https://github.com/arlo-phoenix/CTranslate2-rocm.git)
* WhisperX WebUI: [latest](https://github.com/jhj0517/Whisper-WebUI.git)


### ROCm-6.4.0: Build/Install WhisperX on RX5(x)0/GFX803
> [!NOTE]
> It takes a lot of time to (re)-compile all this Stuff for your GFX803 Card (around 3 hrs)
> Beware you only use Models who fits into your GPU-VRAM

0. build the Docker Baseimage from this GITRepo for gfx803 first.
1. Build the Docker Image for WhisperX, it takes aroud 2,5 hours: `docker build -f Dockerfile_rocm64_whisperx . -t 'rocm64_gfx803_whisperx:latest'`
2. Start the container via `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 7860:7860 -e JOBLIB_MULTIPROCESSING=0 --name rocm64_whisperx rocm64_gfx803_whisperx:latest bash`
3. Open your Webbrowser `http://YOUR_LOCAL_IP:7860` to use WhisperX-WebUI and Download a tiny/small/default LLVM to transcribe
4. Enter to the Dockercontainer `docker exec -ti rocm64_gfx803_whisperx:latest bash` and use `amdgpu_top` to monitor your GPU



