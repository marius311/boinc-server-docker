#===============================
FROM debian:stretch-slim as base
#===============================

MAINTAINER Marius Millea <mariusmillea@gmail.com>

# install necessary packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dh-autoreconf \
        g++ \ 
        git \
        libcurl4-gnutls-dev \
        default-libmysqlclient-dev \
        libssl-dev \
        m4 \
        make \
        mysql-client \
        php7.0-cli \
        php7.0-mysql \
        php7.0-xml \
        pkg-config \
        python \
        python-mysqldb \
    && rm -rf /var/lib/apt/lists

# build args from the docker-compose.yml / .env files
ARG BOINC_USER
ARG PROJECT_ROOT
ENV BOINC_USER=$BOINC_USER \
    PROJECT_ROOT=$PROJECT_ROOT \
    USER=$BOINC_USER \
    HOME=/home/$BOINC_USER



#=======================
FROM base as makeproject
#=======================

# set up the non-root user who compiles the server
RUN adduser $BOINC_USER --disabled-password --gecos ""
USER $BOINC_USER

# get source and compile server 
# TODO: use `--chown=$BOINC_USER` instead of hardcoding the uid, once that
# feature is added to Docker (https://github.com/moby/moby/issues/35018)
COPY --chown=1000 boinc $HOME/boinc
RUN cd $HOME/boinc && ./_autosetup && ./configure --disable-client --disable-manager && make

# ensure the project/secrets volumes have the right permissions when mounted
RUN mkdir $PROJECT_ROOT.dst $HOME/secrets && chown $BOINC_USER:$BOINC_USER $PROJECT_ROOT.dst $HOME/secrets

# first step of the project-making script, which does everything else that can
# be done at Docker build-time (ie without a database)
COPY makeproject-step1.sh /usr/bin/
RUN makeproject-step1.sh

# copy in other project files
COPY --chown=1000 db_dump_spec.xml $PROJECT_ROOT/
COPY --chown=1000 html $PROJECT_ROOT/html
COPY --chown=1000 secrets.env $HOME/secrets

# finish up 
WORKDIR $PROJECT_ROOT
COPY makeproject-step2.sh /usr/bin/
CMD makeproject-step2.sh



#===============
FROM base as b2d
#===============

# do boinc2docker as a separate layer so we don't have to keep re-downloading
# things whenever the build cache is invalidated

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        python-yaml \
        wget
        
# the version of vboxwrapper/iso/appver installed is specified in
# boinc2docker/boinc2docker.yml
COPY boinc2docker /root/boinc2docker
RUN /root/boinc2docker/boinc2docker_create_app --download_only



#==================================
FROM makeproject as makeproject-b2d
#==================================

# copy/install extra things needed for the `-b2d` version

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python-yaml \
        wget \
    && rm -rf /var/lib/apt/lists
USER $BOINC_USER

COPY --from=b2d --chown=1000 /root/boinc2docker $HOME/boinc2docker 
ENV PATH=$HOME/boinc2docker:$PATH
RUN boinc2docker_create_app --projhome $HOME/project
