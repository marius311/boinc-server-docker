FROM php:5.6.17-apache

MAINTAINER Marius Millea <mariusmillea@gmail.com>

#install packages 
RUN apt-get update && apt-get install -y \
        cron \
        libjpeg62-turbo-dev \
        libpng12-dev \
        mysql-client \
        python \
        rsyslog \
        supervisor

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
RUN echo "umask 0002" >> /etc/apache2/envvars

#build configuration
ENV PROJHOME=/project
RUN ln -s $PROJHOME/boincserver.httpd.conf /etc/apache2/sites-enabled/boincserver.httpd.conf 
WORKDIR $PROJHOME

#set up supervisor to run
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
