FROM debian:jessie-slim

LABEL maintainer="Marius Millea <mariusmillea@gmail.com>"

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

# build args from the docker-compose.yml / .env files
ARG BOINC_USER
ARG PROJECT_ROOT
ARG MYSQL_PASSWORD
ENV BOINC_USER=$BOINC_USER USER=$BOINC_USER HOME=/home/$BOINC_USER MYSQL_PASSWORD=$MYSQL_PASSWORD

# set up the non-root user who compiles the server
RUN adduser $BOINC_USER --disabled-password --gecos ""
USER $BOINC_USER

# get source and compile server 
# TODO: use `--chown=$BOINC_USER` instead of hardcoding, once that feature is added to
# Docker (https://github.com/moby/moby/issues/35018)
COPY --chown=1000 boinc $HOME/boinc
RUN cd $HOME/boinc && ./_autosetup && ./configure --disable-client --disable-manager && make

# this script runs boinc/tools/make_project and does everything else that can be
# done at Docker build-time (ie without a database)
COPY makeproject-step1.sh /usr/bin/
RUN makeproject-step1.sh

# copy in other project files
COPY --chown=1000 db_dump_spec.xml $PROJECT_ROOT/
COPY --chown=1000 html $PROJECT_ROOT/html
COPY --chown=1000 bin $PROJECT_ROOT/bin

# ensure the project volume has the right permissions when mounted
RUN mkdir $PROJECT_ROOT.dst && chown $BOINC_USER:$BOINC_USER $PROJECT_ROOT.dst

# finish up 
WORKDIR $PROJECT_ROOT
COPY makeproject-step2.sh devproject.sh /usr/bin/
CMD makeproject-step2.sh
