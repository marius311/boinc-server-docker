FROM php:5.6.17-apache

MAINTAINER Marius Millea <mariusmillea@gmail.com>

#install packages 
RUN apt-get update && apt-get install -y \
        cron \
        git \
        mysql-client \
        python \
        rsyslog \
        supervisor \
        vim

#configure server
RUN docker-php-ext-install mysqli 
RUN a2enmod cgi

#see https://github.com/docker/docker/issues/14651
RUN rm -rf /root && mkdir /root && chmod 755 /root

#so that www-data can read/write boinc server files (boinc server runs as root)
RUN adduser www-data root
COPY .bashrc /root/.bashrc
RUN echo "umask 0002" >> /etc/apache2/envvars

#convenient when exec'ing in
WORKDIR /root/projects/boincserver

RUN ln -s /root/projects/boincserver/boincserver.httpd.conf /etc/apache2/sites-enabled/boincserver.httpd.conf 

#set up supervisor to run
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
