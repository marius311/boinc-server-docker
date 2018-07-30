#!/bin/bash

FILE=/home/$BOINC_USER/secrets/secrets.env && test -f $FILE  && source $FILE

export MYSQL_USER=$BOINC_USER
export MYSQL_PASSWORD=${DB_PASSWD:-password}
export MYSQL_DATABASE=$PROJECT
export MYSQL_RANDOM_ROOT_PASSWORD=yes

source docker-entrypoint-2.sh
