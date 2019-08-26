FROM ubuntu

LABEL maintainer="miles@milescrabill.com"

ENV GOPATH=/go
RUN mkdir ${GOPATH}
ENV PATH=${PATH}:${GOPATH}/bin:/usr/local/bin

# see: https://click.palletsprojects.com/en/7.x/python3/#python3-surrogates
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# prevents interactive installation
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# needed for add-apt-repository
RUN apt update && \
    apt install -y software-properties-common

# ppa for go
RUN add-apt-repository -y ppa:longsleep/golang-backports

# ppa for python
ENV PYTHON_VERSION=python3.7
RUN add-apt-repository -y ppa:deadsnakes/ppa

RUN apt update && \
    apt install -y build-essential git && \
    apt install -y vagrant virtualbox && \
    apt install -y python3-pip && \
    apt install -y curl git jq && \
    apt install -y golang-go && \
    apt install -y python3.7

RUN python3.7 -m pip install pip pipenv

# we need an up to date version of packer
# RUN go get -u github.com/hashicorp/packer
RUN go get -u github.com/hashicorp/packer && \
    cd ${GOPATH}/src/github.com/hashicorp/packer && \
    go install .

WORKDIR /monopacker

COPY ./Pipfile /monopacker/
COPY ./Pipfile.lock /monopacker

RUN pipenv install && pipenv run pip list
RUN export PATH=${PATH}:"$(pipenv --venv)/bin"

ENTRYPOINT ["pipenv", "run"]
CMD make validate
