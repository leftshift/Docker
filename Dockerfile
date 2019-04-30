FROM ubuntu:latest

# Set locale for pip
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt -yqq update  \
 && apt -yqq upgrade \
 && apt -yqq install \
    # python build dependencies \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    # core dependencies \
    git \
    yarn \
    imagemagick \
    ffmpeg \
    curl

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
 |  apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
 |  tee /etc/apt/sources.list.d/yarn.list

# install anfora
COPY anfora/ /opt/anfora/
WORKDIR /opt/anfora/src/

# install anfora client
RUN rmdir client && git clone https://github.com/anforaProject/client.git

WORKDIR /opt/anfora
RUN pip3 install pipenv \
 && pipenv install --python python3.6

WORKDIR /opt/anfora/src/client
RUN yarn install && yarn build

# TODO: Find better way to give config
WORKDIR /opt/anfora/src
RUN pipenv run python commands.py -s --config config/docker.yaml

