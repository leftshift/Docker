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
    imagemagick \
    ffmpeg \
    curl

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
 |  apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
 |  tee /etc/apt/sources.list.d/yarn.list \
 && apt -yqq update \
 && apt -yqq install yarn

# install pipenv
RUN pip3 install pipenv

# install anfora dependencies
COPY anfora/Pipfile /opt/anfora/Pipfile
COPY anfora/Pipfile.lock /opt/anfora/Pipfile.lock
WORKDIR /opt/anfora
RUN pipenv install --python python3.6

# install rest of anfroa
COPY anfora/ /opt/anfora/

# add entrypoint script
COPY entrypoint.sh /opt/anfora/

ENTRYPOINT ["/opt/anfora/entrypoint.sh"]
