# the tag this Dockerfile will build, either "-b2d" or ""
ARG TAG

#=====================================
FROM php:7.0.31-apache-stretch AS base
#=====================================

LABEL maintainer="Marius Millea <mariusmillea@gmail.com>"

# install packages 
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        cron \
        default-mysql-client \
        inotify-tools \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmariadbclient18 \
        nano \
        openssl \
        python \
        rsyslog \
        supervisor \
        vim-tiny \
        wget \
    && wget https://psysh.org/psysh -O /usr/bin/psysh \
    && chmod +x /usr/bin/psysh \
    && rm -rf /var/lib/apt/lists

# configure server
RUN docker-php-ext-install mysqli \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && a2enmod cgi

# logrotate
COPY --chown=1000:1000 logrotate /etc/logrotate.d/boincserver
RUN chmod 644 /etc/logrotate.d/boincserver

# set up supervisor to run
COPY makeproject-step3.sh /usr/bin/
COPY supervisord.conf /etc/supervisor/conf.d/
CMD ["/usr/bin/supervisord"]



#====================
FROM base AS base-b2d
#====================

# install Docker client
RUN curl -L http://get.docker.com/builds/Linux/x86_64/docker-1.10.3 > /usr/bin/docker \
    && chmod +x /usr/bin/docker
    
    
    
#======================
FROM base$TAG AS apache
#======================

# everything which depends on build-args is done as ONBUILD in this stage, so
# the user can customize it

ONBUILD ARG BOINC_USER
ONBUILD ARG PROJECT_ROOT
ONBUILD ENV BOINC_USER=$BOINC_USER \
            PROJECT_ROOT=$PROJECT_ROOT \
            USER=$BOINC_USER \
            HOME=/home/$BOINC_USER \
            MYSQL_HOST=mysql

# set up the non-root user who runs the dameons
ONBUILD RUN adduser $BOINC_USER --disabled-password --gecos ""

# so that www-data can read/write boinc server files
ONBUILD RUN adduser www-data $BOINC_USER

# ensure the project volumes have the right permissions when mounted
ONBUILD RUN mkdir $PROJECT_ROOT && chown $BOINC_USER:$BOINC_USER $PROJECT_ROOT

ONBUILD WORKDIR $PROJECT_ROOT


#================================
FROM apache AS apache-defaultargs
#================================

# this triggers the ONBUILD directives using the default ARGs so we also get a
# fully built example image
