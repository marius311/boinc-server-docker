FROM php:5.6.31-apache

MAINTAINER Marius Millea <mariusmillea@gmail.com>

#add dependent packages
RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >/tmp/jessie-backports.list
RUN cp /tmp/jessie-backports.list /etc/apt/sources.list.d/
RUN rm /tmp/jessie-backports.list

#install libssl and openssl
RUN apt-get update && apt-get install -y -t jessie-backports \
        libssl1.0.0 \
        openssl

#install packages 
RUN apt-get update && apt-get install -y \
        cron \
        libjpeg62-turbo-dev \
        libpng12-dev \
        mysql-client \
        nano \
        python \
        rsyslog \
        supervisor \
        vim-tiny \
        wget \
    && wget https://git.io/psysh -O /usr/bin/psysh \
    && chmod +x /usr/bin/psysh

#configure server
RUN docker-php-ext-install mysqli \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && a2enmod cgi

#see https://github.com/docker/docker/issues/14651
RUN rm -rf /root && mkdir /root && chmod 755 /root

#so that www-data can read/write boinc server files (boinc server runs as root)
RUN adduser www-data root
COPY .bashrc /root/.bashrc

#build configuration
ENV PROJHOME=/root/project
RUN ln -s $PROJHOME/boincserver.httpd.conf /etc/apache2/sites-enabled/boincserver.httpd.conf 
WORKDIR $PROJHOME

#logrotate
COPY logrotate /etc/logrotate.d/boincserver
RUN chmod 644 /etc/logrotate.d/boincserver

#set up supervisor to run
COPY start_project /usr/bin/start_project
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
