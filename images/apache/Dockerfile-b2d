FROM php:5.6.31-apache

LABEL maintainer="Marius Millea <mariusmillea@gmail.com>"

#install packages 
RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        cron \
        inotify-tools \
        libjpeg62-turbo-dev \
        libpng12-dev \
        mysql-client \
        nano \
        python \
        rsyslog \
        supervisor \
        vim-tiny \
        wget \
    && apt-get install -y -t jessie-backports openssl \
    && wget https://git.io/psysh -O /usr/bin/psysh \
    && chmod +x /usr/bin/psysh \
    && rm -rf /var/lib/apt/lists

#configure server
RUN docker-php-ext-install mysqli \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && a2enmod cgi

#install Docker client
RUN curl -L http://get.docker.com/builds/Linux/x86_64/docker-1.10.3 > /usr/bin/docker \
    && chmod +x /usr/bin/docker

#see https://github.com/docker/docker/issues/14651
RUN rm -rf /root && mkdir /root && chmod 755 /root

#so that www-data can read/write boinc server files (boinc server runs as root)
RUN adduser www-data root
COPY .bashrc /root/.bashrc

# these can't be changed (yet). for variables which *can* be changed, see the .env file
ENV PROJECT_ROOT=/root/project
WORKDIR $PROJECT_ROOT

#logrotate
COPY logrotate /etc/logrotate.d/boincserver
RUN chmod 644 /etc/logrotate.d/boincserver

#set up supervisor to run
COPY post-makeproject.sh /usr/bin/
COPY supervisord.conf /etc/supervisor/conf.d/
CMD ["/usr/bin/supervisord"]
