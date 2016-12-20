FROM ubuntu:16.04

RUN apt-get update \ 
    && apt-get install -y \
        net-tools \
        openssh-server \
        rsyslog \
        supervisor \
    && mkdir -p /home/sshgrid/.ssh /var/run/sshd \
    && useradd sshgrid

COPY sshd_config /etc/ssh/sshd_config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

CMD ["/usr/bin/supervisord"]
