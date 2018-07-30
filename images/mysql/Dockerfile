FROM mariadb:10.3.8-bionic

COPY my.cnf /etc/mysql/conf.d/my.cnf

# removes the part of the script that creates $MYSQL_DATABASE (that's done by
# makeproject-step2.sh), but keeps the part that grants $BOINC_USER permissions
# to $MYSQL_DATABASE (this we do want)
RUN sed -i "/file_env 'MYSQL_DATABASE'/,+5d" /usr/local/bin/docker-entrypoint.sh \
    && mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-2.sh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
