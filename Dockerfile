# Docker Buildfile for ROCm 6.3 to use ComfyUI with a RX570 / Polaris / gfx803 AMD GPU
# created, build and compiled by Robert Rosenbusch at December 2024

FROM rocm/pytorch:rocm6.3_ubuntu24.04_py3.12_pytorch_release_2.4.0

ENV PORT=8188 \
    COMMANDLINE_ARGS='' \
    ### how many CPUCores are using while compiling
    MAX_JOBS=14 \ 
    ### Settings for AMD GPU RX570/RX580/RX590 GPU
    HSA_OVERRIDE_GFX_VERSION=8.0.3 \ 
    PYTORCH_ROCM_ARCH=gfx803 \
    ROCM_ARCH=gfx803 \ 
    TORCH_BLAS_PREFER_HIPBLASLT=0\ 
    ROC_ENABLE_PRE_VEGA=1 \
    USE_CUDA=0 \  
    USE_ROCM=1 \ 
    USE_NINJA=1 \
    FORCE_CUDA=1 \ 
    #TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 \
    #PYTORCH_TUNABLEOP_ENABLED=1 \
#######
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONENCODING=UTF-8\      
    REQS_FILE='requirements.txt' \
    PIP_ROOT_USER_ACTION='ignore' \
    COMMANDLINE_ARGS='' 

## Write the Environment VARSs to global... to compile later with while you use #docker save# or #docker commit#
RUN echo MAX_JOBS=${MAX_JOBS} >> /etc/environment && \ 
    echo HSA_OVERRIDE_GFX_VERSION=${HSA_OVERRIDE_GFX_VERSION} >> /etc/environment && \ 
    echo PYTORCH_ROCM_ARCH=${PYTORCH_ROCM_ARCH} >> /etc/environment && \ 
    echo ROCM_ARCH=${ROCM_ARCH} >> /etc/environment && \ 
    echo TORCH_BLAS_PREFER_HIPBLASLT=${TORCH_BLAS_PREFER_HIPBLASLT} >> /etc/environment && \ 
    echo ROC_ENABLE_PRE_VEGA=${ROC_ENABLE_PRE_VEGA} >> /etc/environment && \
    echo USE_CUDA=${USE_CUDA} >> /etc/environment && \
    echo USE_ROCM=${USE_ROCM} >> /etc/environment && \
    echo USE_NINJA=${USE_NINJA} >> /etc/environment && \
    echo FORCE_CUDA=${FORCE_CUDA} >> /etc/environment && \
    #echo TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=${TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL} >> /etc/environment && \
    #echo PYTORCH_TUNABLEOP_ENABLED=${PYTORCH_TUNABLEOP_ENABLED} >> /etc/environment && \
    echo PIP_ROOT_USER_ACTION=${PIP_ROOT_USER_ACTION} >> /etc/environment && \
    true

## Export the AMD Stuff
RUN export MAX_JOBS=${MAX_JOBS} && \ 
    export HSA_OVERRIDE_GFX_VERSION=${HSA_OVERRIDE_GFX_VERSION} && \
    export ROC_ENABLE_PRE_VEGA=${ROC_ENABLE_PRE_VEGA} && \
    export PYTORCH_ROCM_ARCH=${PYTORCH_ROCM_ARCH} && \
    export ROCM_ARCH=${ROCM_ARCH} && \
    export TORCH_BLAS_PREFER_HIPBLASLT=${TORCH_BLAS_PREFER_HIPBLASLT} && \    
    export USE_CUDA=${USE_CUDA}  && \
    export USE_ROCM=${USE_ROCM}  && \
    export USE_NINJA=${USE_NINJA} && \
    export FORCE_CUDA=${FORCE_CUDA} && \
    #export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=${TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL} && \
    #export  PYTORCH_TUNABLEOP_ENABLED=${PYTORCH_TUNABLEOP_ENABLED} && \
    export PIP_ROOT_USER_ACTION=${PIP_ROOT_USER_ACTION} && \
    true

# Update System and install ffmpeg for SDXL video and python virtual Env
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ffmpeg virtualenv google-perftools ccache tmux mc pigz plocate && \
    pip install --upgrade pip wheel && \
    pip install cmake mkl mkl-include && \ 
    apt --fix-broken install -y && \
    true


ENV ROCBLAS_GIT_VERSION="rocm-6.3.0"
RUN echo "Checkout ROCBLAS: ${ROCBLAS_GIT_VERSION}" && \
    git clone https://github.com/ROCm/rocBLAS.git -b ${ROCBLAS_GIT_VERSION} /rocblas && \
    true

WORKDIR /rocblas

RUN echo "BUILDING rocBLAS with ARCH: ${ROCM_ARCH} and JOBS: ${MAX_JOBS}" && \
    ./install.sh -ida ${ROCM_ARCH} -j ${MAX_JOBS} && \
    true

###########
##
# git clone PyTorch Version you need for
### Build PyTorch

ENV PYTORCH_GIT_VERSION="rocm6.3_it_with_prebuilt_aot"
RUN echo "Checkout PyTorch Version: ${PYTORCH_GIT_VERSION} " && \  
    git clone --recursive https://github.com/ROCm/pytorch.git -b ${PYTORCH_GIT_VERSION} /pytorch && \
    true

#WORKDIR /var/lib/jenkins/pytorch
WORKDIR /pytorch
RUN echo "BULDING PYTORCH $(git describe --tags --exact | sed 's/^v//')" && \
    mkdir -p /pytorch/dist && \
    true 

RUN python --version && \
     python setup.py clean && \
     pip install -r ${REQS_FILE} && \
     true
   

RUN python3 tools/amd_build/build_amd.py && \
     true

RUN echo "** BUILDING PYTORCH *** " && \ 
     python3 setup.py bdist_wheel && \
     true

RUN echo "** INSTALL PYTORCH ***" && \    
     pip install dist/torch*.whl && \
     true     


### Build Vision

#git clone Torchvision Version you need
## Torchvision Version
ENV TORCH_GIT_VERSION="release/0.20"
#ENV TORCH_GIT_VERSION="nightly"
RUN echo "Checkout Torchvision Version: ${TORCH_GIT_VERSION} " && \ 
   git clone https://github.com/pytorch/vision.git -b ${TORCH_GIT_VERSION} /vision && \
   true

#WORKDIR /var/libs/jenkins/vision
WORKDIR /vision

RUN python3 setup.py bdist_wheel && \
    pip install dist/torchvision-*.whl && \
    mkdir -p /vision/dist && \
    true


#RUN cp /var/lib/jenkins/vision/dist/*.whl /vision/dist && \
#    cp /var/lib/jenkins/pytorch/dist/*.whl /pytorch/dist  && \
#    true

######
# End of building pytorch and torchvision WHL-Files
###########

EXPOSE ${PORT}

CMD ["/bin/bash","-c"]