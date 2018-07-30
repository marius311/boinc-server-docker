FROM php:7.0.31-apache-stretch

MAINTAINER Marius Millea <mariusmillea@gmail.com>

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
    && wget https://git.io/psysh -O /usr/bin/psysh \
    && chmod +x /usr/bin/psysh \
    && rm -rf /var/lib/apt/lists

# configure server
RUN docker-php-ext-install mysqli \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && a2enmod cgi
    
# build args from the docker-compose.yml / .env files
ARG BOINC_USER
ARG PROJECT_ROOT
ENV USER=$BOINC_USER \
    BOINC_USER=$BOINC_USER \
    HOME=/home/$BOINC_USER \
    PROJECT_ROOT=$PROJECT_ROOT \
    MYSQL_HOST=mysql

# set up the non-root user who runs the dameons
RUN adduser $BOINC_USER --disabled-password --gecos ""

# so that www-data can read/write boinc server files
RUN adduser www-data $BOINC_USER

# a prettier shell
COPY --chown=1000:1000 .bashrc $HOME/.bashrc

# logrotate
COPY --chown=1000:1000 logrotate /etc/logrotate.d/boincserver
RUN chmod 644 /etc/logrotate.d/boincserver

# ensure the project/secrets volumes have the right permissions when mounted
RUN mkdir $PROJECT_ROOT $HOME/secrets && chown $BOINC_USER:$BOINC_USER $PROJECT_ROOT $HOME/secrets

# set up supervisor to run
COPY makeproject-step3.sh /usr/bin/
COPY supervisord.conf /etc/supervisor/conf.d/
CMD ["/usr/bin/supervisord"]
