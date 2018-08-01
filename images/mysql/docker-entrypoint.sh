#!/bin/bash

# get DB_PASSWD from secrets file
echo "Waiting for secrets file..."
SECRETS_ENV=/run/secrets/secrets.env
while [ ! -f $SECRETS_ENV ] ; do sleep 1; done
source $SECRETS_ENV

export MYSQL_USER=$BOINC_USER
export MYSQL_PASSWORD=$DB_PASSWD
export MYSQL_DATABASE=$PROJECT
export MYSQL_RANDOM_ROOT_PASSWORD=yes

source docker-entrypoint-2.sh
