FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y 
RUN apt-get install -y \
    vim \
    git \
    curl \
    cmake \
    gcc\ 
    llvm-dev \
    sudo \
    wget && \
    rm -rf /var/lib/apt/lists/*
    # RUN apt-get install libfmt-dev

RUN apt-get update && apt-get install -y build-essential
RUN apt-get update && apt-get install -y \
    libboost-dev \
    libboost-serialization-dev \
    libboost-iostreams-dev
RUN apt-get install libfmt-dev -y

# Setup TEST directory structure
RUN mkdir /root/TESTS
RUN mkdir /root/TESTS/newgr_autoevolve
RUN mkdir /root/SHELL_SCRIPTS

# Setup shell
COPY .vimrc /root/.vimrc
COPY .bashrc /root/.bashrc
COPY ./SHELL_SCRIPTS/*.sh /root/SHELL_SCRIPTS

# Setup Codex and SSH config
WORKDIR /root/
# COPY .codex .codex 
RUN wget https://github.com/openai/codex/releases/download/rust-v0.104.0/codex-x86_64-unknown-linux-musl.tar.gz
RUN tar -xzvf codex-x86_64-unknown-linux-musl.tar.gz
RUN rm -rf codex-x86_64-unknown-linux-musl.tar.gz
COPY .flute-3.1 .flute-3.1

# Setup and test ssh
RUN ssh -T git@github.com || true
# Setup OR and ORFS : 
RUN git clone https://github.com/taizun-jj202/OpenROAD_New_GRT.git
WORKDIR /root/OpenROAD_New_GRT
RUN git submodule update --init --recursive
RUN ./etc/DependencyInstaller.sh -all

WORKDIR /root/
RUN git clone https://github.com/taizun-jj202/OpenROAD-flow-scripts_New_GRT.git /root/OpenROAD-flow-scripts
# WORKDIR /root/OpenROAD-flow-scripts
# RUN ./setup.sh 
# RUN ./etc/DependencyInstaller.sh -all
# RUN ./build_openroad.sh --local

CMD ["/bin/bash"]


