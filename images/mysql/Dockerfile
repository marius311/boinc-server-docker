FROM mysql:5.7.19

COPY my.cnf /etc/mysql/conf.d/my.cnf

ARG BOINC_USER
ARG MYSQL_PASSWORD
ARG PROJECT

ENV MYSQL_USER=$BOINC_USER
ENV MYSQL_PASSWORD=$MYSQL_PASSWORD
ENV MYSQL_DATABASE=$PROJECT
ENV MYSQL_RANDOM_ROOT_PASSWORD=yes

# removes the part of the script that creates $MYSQL_DATABASE, but keeps the
# part that grants #BOINC_USER permissions to #MYSQL_DATABASE (which we do want)
RUN sed -i "/file_env 'MYSQL_DATABASE'/,+5d" /usr/local/bin/docker-entrypoint.sh
