FROM php:5.6.17-apache

MAINTAINER Marius Millea <mariusmillea@gmail.com>

#install packages 
RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
        cron \
        libjpeg62-turbo-dev \
        libpng12-dev \
        mysql-client \
        python \
        python-certbot-apache \
        rsyslog \
        supervisor

#configure server
RUN docker-php-ext-install mysqli \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && a2enmod cgi ssl

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
COPY wait_for_project /usr/bin/wait_for_project
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
