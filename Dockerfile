FROM nvidia/cuda:7.5-cudnn4-devel

MAINTAINER Kyunghyun Paeng <khpaeng@lunit.io>

RUN ["/bin/bash"]

# Set up personal libraries
#RUN apt-get update && apt-get install -y --no-install-recommends \
#        build-essential \
#        curl \
        
