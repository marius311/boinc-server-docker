FROM debian:jessie-slim

MAINTAINER Marius Millea <mariusmillea@gmail.com>

# install necessary packages
RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dh-autoreconf \
        g++ \ 
        git \
        libcurl4-gnutls-dev \
        libmysqlclient-dev \
        m4 \
        make \
        mysql-client \
        php5-cli \
        php5-mysql \
        pkg-config \
        python \
        python-mysqldb \
    && apt-get install -y -t jessie-backports libssl-dev \
    && rm -rf /var/lib/apt/lists

# get source and compile server
COPY boinc /root/boinc
RUN cd /root/boinc && ./_autosetup && ./configure --disable-client --disable-manager && make

# these can't be changed (yet). for variables which *can* be changed, see the .env file
ENV USER=root PROJECT_ROOT=/root/project

# make project
COPY makeproject-step1.sh /usr/bin/
RUN makeproject-step1.sh

# project files
COPY db_dump_spec.xml $PROJECT_ROOT/
COPY html $PROJECT_ROOT/html
COPY bin $PROJECT_ROOT/bin

# finish up 
WORKDIR $PROJECT_ROOT
COPY makeproject-step2.sh devproject.sh /usr/bin/
CMD makeproject-step2.sh
