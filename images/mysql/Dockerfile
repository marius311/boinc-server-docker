#==================================
FROM mariadb:10.3.8-bionic AS mysql
#==================================

# removes the part of the script that creates $MYSQL_DATABASE, which is done
# instead by makeproject-step2.sh
RUN sed -i "/file_env 'MYSQL_DATABASE'/,+5d" /usr/local/bin/docker-entrypoint.sh \
    && mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-2.sh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ONBUILD ARG BOINC_USER
ONBUILD ARG PROJECT
ONBUILD ENV BOINC_USER=$BOINC_USER \
            PROJECT=$PROJECT



#==============================
FROM mysql AS mysql-defaultargs
#==============================

# this triggers the ONBUILD directives using the default ARGs so we also get a
# fully built example image
