# ROCm 6.3.0, PyTorch 2.5, Torchvision 0.20 with AMD GFX803 aka AMD Polaris aka AMD RX570/RX580/RX590 for ComfyUI, Ollama an whisperX

This repo provides a docker main buildfile based on the original AMD ROCm-Dockerimage to compile PyTorch and Torchvision/Torchaudio for the [AMD RX570/RX580/RX590](https://en.wikipedia.org/wiki/Radeon_500_series) generation to generate AI Pics on ComfyUI, fast automatic speech recognition with WhisperX, PyTorch and a Dockerfile to build Ollama on the same ROCm Stack. 

PyTorch, Torchvision _and_ rocBLAS-Library are not compiled to use the GPU-Polaris generation in the original PIP repository. And of course not compiled too in the official ROCm-PyTorch Dockerfile. However, if Polaris 20/21 GPU support is to be used in ComfyUI or WhisperX, there is no way around newly compiled PyTorch and Torchvision/Torchaudio whl/wheel python files. And for Ollama in ROCm 6.X you have to recompile the rocBLAS-Library too. That what this Docker Buildfile(s) will do for you.

> [!IMPORTANT]
> Before you start to build the Specific Container on what AI-App you wanna use for your GFX803-GPU, please check up the next few hints. It could save Lifetime to debug and prevent bad moods or throwing away your gfx803-GPU in a big bow.

> [!NOTE]
> #### At General
> 1. This is an hobby enthusiastic Project into my freetime. gfx803 is not supported since over two years on any Linux-Distro and was never designed to do some AI-Stuff. So be carefull.
> 2. The published Dockercontainers downloaded a lot of stuff and needed a lot of time and storage space to recompile the neccesarry Stuff for gfx803. Big aware, its not my fault.
> 3. Make sure you had have a good ISP-Connection, around 100 Gig free Storage and one to three hours time to recompile, depends what kind of APP you wanna use.

> [!NOTE]
> 1. Make sure, that both Kernel-Devices `/dev/dri` and `/dev/kfd` are aviable 
> 2. Make sure, your Mainboard support [PCIe atomic](https://github.com/ROCm/ROCm/issues/2224#issuecomment-2299689450)  `sudo grep flags /sys/class/kfd/kfd/topology/nodes/*/io_links/0/properties`

> [!NOTE]
> 1. Make sure your user to start the Dockercontainer is a member of both groups `render`and `video`. 
> 2. it could be possible (depends on your Linux-Distro) to add [a udev-Rulel](https://github.com/ROCm/ROCm/issues/1798#issuecomment-1849112550). 

> [!TIP]
> You should reboot after adding groups to your user.


> [!CAUTION]
> After some research/feedback from Users who are using Dockercontainer from this GIT in [Ollama](https://github.com/robertrosenbusch/gfx803_rocm/issues/8#issue-2919996555) and [PyTorch/ComfyUI](https://github.com/robertrosenbusch/gfx803_rocm/issues/13#issuecomment-2754796999), cause the devices `/dev/dri` and  `/dev/kfd` crashed with SegFaults. Please proofe your used Linux-Kernel Version and switch up or down to a well know working Kernel-Version. Fedora 41, Arch and Debian 13 using (in April 2015) suspected Linux-Kernel-Versions as default.
> |Kernel Version|5.19|6.2|6.8|6.9|6.10|6.11|6.12|6.13|6.14|
> |--------------|-----|-----|------|-----|------|-----|-----|-----|-----|
> |working on Ollama/PyTorch|✅|✅|✅|✅|✅|✅|🟥|🟥|✅|


## ROCm-6.3.0 PyTorch for ComfyUI in a Dockerfile

|OS            |Python|ROCm |PyTorch|Torchvision|GPU|
|--------------|------|-----|-----|-----|-----|
any current LinuxDistro|3.12|6.3.0|2.5.1|0.20.0|RX570/580/590 aka Polaris 20/21 aka GCN 4|

* Used ROCm Docker Version: [rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0](https://hub.docker.com/layers/rocm/pytorch/rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0/images/sha256-98ddf20333bd01ff749b8092b1190ee369a75d3b8c71c2fac80ffdcb1a98d529?context=explore)     
* PyTorch GIT: [v2.5.1](https://github.com/ROCm/pytorch/tree/release/2.5)
* Torchvison GIT: [v0.20.0](https://github.com/pytorch/vision/releases/tag/v0.20.0)
* rocBLAS Library: [6.3.0](https://github.com/ROCm/rocBLAS/releases/tag/rocm-6.3.0)

##### ROCm-6.3.0 ComfyUI Benchmark on RX570
|       |SDXL  (1024x1024)|SD 1.5  (512x512)|SD 1.5  (512x768)|Flux -Schnell (1024x1024)|SD3.5  (1024x1024)|
|--------------|-----|------|-----|-----|-----|
|ROCm 6.3 + PyTorch v2.5 (RX570)|[63.72 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_schnell_1024x1024.png)|[19.56 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd35_1024x1024.png)|[7.57 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sdxl_1024x1024l.png)| [1.19 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd15_512x512_sd.png)|[1.92 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd15_512x768_sd.png)|
|ROCm 6.3 + PyTorch v2.5 (RX590)|[63.72 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_schnell_1024x1024.png)|[19.56 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd35_1024x1024.png)|[7.57 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sdxl_1024x1024l.png)| [1.19 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd15_512x512_sd.png)|[1.92 s/it](https://github.com/robertrosenbusch/gfx803_rocm/tree/main/benchmark/comfyui_sd15_512x768_sd.png)|
|ROCm 5.7 + PyTorch v2.3|58.85 s/it|19.87 s/it|8.33 s/it|1.22 s/it|1.97 s/it|


## ROCm-6.3.0 Ollama / Webopen-webui in a Dockerfile

|OS            |linux|Python|ROCm |Ollama|GPU|Mapping Port|
|--------------|-----|------|-----|------|-----|-----|
|Ubuntu-24.04|6.X and 5.19 |3.12|6.3.0|v0.5.12|RX570/580/590 aka Polaris 20/21 aka GCN 4|8080,11434|
* Used ROCm Docker Version: [rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0](https://hub.docker.com/layers/rocm/pytorch/rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0/images/sha256-98ddf20333bd01ff749b8092b1190ee369a75d3b8c71c2fac80ffdcb1a98d529?context=explore)     
* rocBLAS Library: [6.3.0](https://github.com/ROCm/rocBLAS/releases/tag/rocm-6.3.0)
* Ollama : [v0.6.4](https://github.com/ollama/ollama/releases/tag/v0.6.4)
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
5. Enter to the Dockercontainer `docker exec -ti rocm63_ollama bash`
6. [download a model](https://ollama.com/search) you need for e.g. `./ollama run deepseek-r1:1.5b`
7. Start Open-WebUI `open-webui serve &` 
8. Open your Webbrowser `http://YOUR_LOCAL_IP:8080` to use Open-WebUI
9. For Benchmark your downloaded Models use `python /llm-benchmark/benchmark.py`


> [!NOTE]
> You should have at least 8 GB of RAM available to run the 7B models, 16 GB to run the 13B models, and 32 GB to run the 33B models.

🚧 **my todoist stats:**
<!-- TODO-IST:START -->
🏆  8,004 Karma Points           
🌸  Completed 0 tasks today           
✅  Completed 673 tasks so far           
⏳  Longest streak is 10 days

- ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) `#f03c15`
- ![#c5f015](https://placehold.co/15x15/c5f015/c5f015.png) `#c5f015`
- ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png) `#1589F0`



🔴🟠🟡🟢🔵🟣🟤⚫⚪🔘🛑⭕

🟥🟧🟨🟩🟦🟪🟫⬛⬜🔲🔳⏹☑✅❎

❤️🧡💛💚💙💜🤎🖤🤍♥️💔💖💘💝💗💓💟💕❣️♡

🔺🔻🔷🔶🔹🔸♦💠💎💧🧊

🏴🏳🚩🏁

◻️◼️◾️◽️▪️▫️
❌ Closed PR
<!-- TODO-IST:END -->

> [!NOTE]
> 1. Make sure, that both Kernel-Devices `/dev/dri` and `/dev/kfd` are aviable 
> 2. Make sure, your Mainboard support [PCIe atomic](https://github.com/ROCm/ROCm/issues/2224#issuecomment-2299689450)  `sudo grep flags /sys/class/kfd/kfd/topology/nodes/*/io_links/0/properties`

> [!NOTE]
> 1. Make sure your user to start the Dockercontainer is a member of both groups `render`and `video`. 
> 2. it could be possible (depends on your Linux-Distro) to add [a udev-Rulel](https://github.com/ROCm/ROCm/issues/1798#issuecomment-1849112550). 

> [!TIP]
> You should reboot after adding groups to your user.


> [!CAUTION]
> After some research in [Ollama](https://github.com/robertrosenbusch/gfx803_rocm/issues/8#issue-2919996555) and [PyTorch/ComfyUI](https://github.com/robertrosenbusch/gfx803_rocm/issues/13#issuecomment-2754796999), cause the devices `/dev/dri` and `/dev/kfd` crashed with SegFaults. Please proofe your used Linux-Kernel Version. Fedora 41 and Debian 13 using (in April 2015) both the suspected Linux-Kernel-Versions
> |Kernel Version|5.19|6.2|6.8|6.9|6.10|6.11|6.12|6.13|6.14|
> |--------------|-----|-----|------|-----|------|-----|-----|-----|-----|
> |working on Ollama/PyTorch|✅|✅|✅|✅|✅|✅|🟥|🟥|✅|

> * Used ROCm Docker Version: [rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0](https://hub.docker.com/layers/rocm/pytorch/rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0/images/sha256-98ddf20333bd01ff749b8092b1190ee369a75d3b8c71c2fac80ffdcb1a98d529?context=explore)     
> * rocBLAS Library: [6.3.0](https://github.com/ROCm/rocBLAS/releases/tag/rocm-6.3.0)
> * Ollama : [v0.5.12](https://github.com/ollama/ollama/releases/tag/v0.5.12)
> * Interactive LLM-Benchmark for Ollama: [latest](https://github.com/willybcode/llm-benchmark.git)


> 1. install the docker-subsystem / docker.io on your linux system
> 2. download the latest file version of this github-repos vi git clone
3. build your Docker image via `docker build -f Dockerfile_rocm63_ollama . -t 'rocm63_ollama:latest'`
4. start the container via: `docker run -it --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 8080:8080 -p 11434:11434 --name rocm63_ollama rocm63_ollama:latest bash`
5. Enter to the Dockercontainer `docker exec -ti rocm63_ollama bash`
6. [download a model](https://ollama.com/search) you need for e.g. `./ollama run deepseek-r1:1.5b`
7. Start Open-WebUI `open-webui serve &` 
8. Open your Webbrowser `http://YOUR_LOCAL_IP:8080` to use Open-WebUI
9. For Benchmark your downloaded Models use `python /llm-benchmark/benchmark.py`


> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]
> Crucial information necessary for users to succeed.

> [!WARNING]
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.