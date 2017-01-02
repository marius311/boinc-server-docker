FROM ubuntu:16.04

RUN apt-get update \ 
    && apt-get install -y \
        python3 \
        net-tools \
        python3-setuptools \
        rsyslog \
        supervisor \
    && pip3 install asyncssh
        
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

CMD ["/usr/bin/supervisord"]
