FROM nvidia/cuda:7.5-cudnn4-devel

MAINTAINER Kyunghyun Paeng <khpaeng@lunit.io>

VOLUME ["/data"]

# Set up personal libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
        vim \
        build-essential \
        curl \
        git \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        python-numpy \
        python-pip \
        rsync \
        software-properties-common \
        swig \
        tmux \
        unzip \
        zip \
        zlib1g-dev \ 
        wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 
# Set up pip libraries (python)
RUN curl -fSsL -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py
RUN pip --no-cache-dir install \
        scipy \
        matplotlib \
        ipython \
        pydicom \
        PyJWT \
        scikit-image

# Set up bazel
RUN add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends openjdk-8-jdk openjdk-8-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN echo "startup --batch" >> /root/.bazelrc
RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone" \
    >>/root/.bazelrc
ENV BAZELRC /root/.bazelrc
ENV BAZEL_VERSION 0.3.0
WORKDIR /
RUN mkdir /bazel && \
    cd /bazel && \
    curl -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    curl -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE.txt && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    cd / && \
    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

RUN mkdir /workspace
RUN mkdir /workspace/lib
WORKDIR /workspace/lib

# Set up tensorflow
RUN git clone -b r0.10 --recursive --recurse-submodules https://github.com/tensorflow/tensorflow.git && \
    cd tensorflow && \
    git checkout r0.10
WORKDIR /workspace/lib/tensorflow
ENV CUDA_TOOLKIT_PATH /usr/local/cuda
ENV CUDNN_INSTALL_PATH /usr/local/cuda
ENV TF_NEED_CUDA 1
RUN ./configure && \
    bazel build -c opt --config=cuda tensorflow/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
    pip install --upgrade /tmp/pip/tensorflow-*.whl

# Set up bash env
ENV CUDA_PATH /usr/local/cuda
COPY .bashrc /root
WORKDIR /workspace
