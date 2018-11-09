# the tag this Dockerfile will build, either "-b2d" or ""
ARG TAG

#===============================
FROM debian:stretch-slim AS base
#===============================

LABEL maintainer="Marius Millea <mariusmillea@gmail.com>"

# install packages
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
        python3 \
        python-mysqldb \
        python3-mysqldb \
    && rm -rf /var/lib/apt/lists

# get source and compile server 
COPY --chown=1000 boinc /usr/local/boinc
RUN cd /usr/local/boinc && ./_autosetup && ./configure --disable-client --disable-manager && make

# project-making scripts
COPY makeproject-step1.sh makeproject-step2.sh /usr/local/bin/

# some other project files (some of which will be put in the correct place with
# ONBUILD instructions later)
COPY --chown=1000 db_dump_spec.xml /.project_root/
COPY --chown=1000 html /.project_root/html/
COPY --chown=1000 secrets.env /run/secrets/

#==============================
FROM debian:stretch-slim AS b2d
#==============================

# do boinc2docker as a separate stage so we don't have to keep re-downloading
# things whenever the build cache is invalidated

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        python-yaml \
        wget

# the version of vboxwrapper/iso/appver installed is specified in
# boinc2docker/boinc2docker.yml
COPY boinc2docker /root/boinc2docker
RUN /root/boinc2docker/boinc2docker_create_app --download_only



#====================
FROM base AS base-b2d
#====================

# copy/install extra things needed for the `-b2d` version

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python-yaml \
        wget \
    && rm -rf /var/lib/apt/lists

COPY --from=b2d --chown=1000 /root/boinc2docker $HOME/boinc2docker 
ENV PATH=$HOME/boinc2docker:$PATH



#===========================
FROM base$TAG AS makeproject
#===========================

# everything which depends on build-args is done as ONBUILD in this stage, so
# the user can customize it

ARG TAG
ENV TAG=$TAG
ONBUILD ARG BOINC_USER
ONBUILD ARG PROJECT_ROOT
ONBUILD ENV BOINC_USER=$BOINC_USER \
            PROJECT_ROOT=$PROJECT_ROOT \
            USER=$BOINC_USER \
            HOME=/home/$BOINC_USER \
            MYSQL_HOST=mysql
    
# set up the non-root user who compiles the server
ONBUILD RUN adduser $BOINC_USER --disabled-password --gecos ""

# ensure the project/secrets volumes have the right permissions when mounted
ONBUILD RUN mkdir $PROJECT_ROOT.dst && chown $BOINC_USER:$BOINC_USER $PROJECT_ROOT.dst

ONBUILD USER $BOINC_USER


# build server
ONBUILD RUN makeproject-step1.sh
ONBUILD RUN test -z "$TAG" || boinc2docker_create_app --projhome $PROJECT_ROOT
ONBUILD CMD makeproject-step2.sh

ONBUILD WORKDIR $PROJECT_ROOT



#==========================================
FROM makeproject AS makeproject-defaultargs
#==========================================

# this triggers the ONBUILD directives using the default ARGs so we also get a
# fully built example image
