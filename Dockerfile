FROM ubuntu:18.04

MAINTAINER Dan Sheffner <Dan@Sheffner.com>

# Copyright (c) Dan Sheffner Digital Imaging Software Solutions, INC
#               Dan@Sheffner.com
# All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish, dis-
# tribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the fol-
# lowing conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABIL-
# ITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
# SHALL THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

# Docker container for golang development
# time docker build . -t thesheff17/govim
# docker run -it thesheff17/govim

# helper ENV variables
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV EDITOR vim
ENV SHELL bash

RUN \
    apt-get install -yq \
    curl \ 
    python-dev \
    python3-dev \
    build-essential \
    cmake \
    git-core \
    wget \
    vim \
    tmux

# golang
RUN  \
    wget -q https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.11.2.linux-amd64.tar.gz 	&& \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /root/.bashrc && \
    echo 'export GOBIN=/root/go/bin' >> /root/.bashrc && \
	echo 'export GOPATH=/root/go/bin' >> /root/.bashrc && \
	rm go1.11.2.linux-amd64.tar.gz

# directories & pathongen
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle ~/.vim/colors/ && \
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# vim sensible
RUN cd ~/.vim/bundle && \
	git clone https://tpope.io/vim/sensible.git

# neo vim
RUN curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh > install.sh && \
  sh ./install.sh 

# colors
RUN cd /root/.vim/colors/ && \
    wget https://raw.githubusercontent.com/shannonmoeller/vim-monokai256/master/colors/monokai256.vim

# vim-go
RUN git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go

# vim setup
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
	git clone https://github.com/fatih/vim-go.git ~/.vim/plugged/vim-go
COPY vimrc /root/.vimrc 
COPY bashrc /root/.bashrc

# YouCompleteMe
RUN cd /root/.vim/bundle/ && \
    export PATH=$PATH:/usr/local/go/bin && \
    git clone https://github.com/Valloric/YouCompleteMe.git && \
    cd /root/.vim/bundle/YouCompleteMe && \
    git submodule update --init --recursive && \
    python3 install.py --clang-completer --go-completer
    
# install a bunch of required packages these need
RUN vim +NeoBundleInstall +qall
RUN export PATH=$PATH:/usr/local/go/bin && vim +'silent :GoInstallBinaries' +qall

# configuring external go scripts I use
RUN export PATH=$PATH:/usr/local/go/bin && go get github.com/y0ssar1an/q

# sample script
RUN mkdir /root/helloWorld/
WORKDIR /root/helloWorld/
COPY ./main.go .
RUN /usr/local/go/bin/go build

COPY ./start_tmux.sh /root/
RUN chmod +x /root/start_tmux.sh
WORKDIR /root/

CMD ["/root/start_tmux.sh"]
