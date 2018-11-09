#!/bin/bash

set -e

cd /usr/local/boinc/tools

./make_project --url_base 'http://${url_host}' \
               --project_host '${project}' \
               --db_host mysql \
               --db_user root \
               --db_passwd '${db_passwd}' \
               --no_db \
               --no_query \
               --project_root $PROJECT_ROOT \
               --delete_prev_inst \
               '${project}'

sed -i -e 's|http://${url_host}|\${url_base}|g' $PROJECT_ROOT/config.xml $PROJECT_ROOT/html/user/schedulers.txt

cp -rT /.project_root $PROJECT_ROOT
rm -rf /.project_root/*

chmod g+w $PROJECT_ROOT/download
rm -r $PROJECT_ROOT/log_*
mkdir $PROJECT_ROOT/html/stats_archive



# collect "secrets" (ie passwords, signing keys, etc...) from the project folder
# and put them in the secrets volume, and add symlinks in their place
SECRETS=/run/secrets

# code signing and upload keys
mv $PROJECT_ROOT/keys $SECRETS
ln -s $SECRETS/keys $PROJECT_ROOT

# ops password
mkdir -p $SECRETS/html/ops
echo "admin:zJiQQ3OoIfehM" > $SECRETS/html/ops/.htpasswd
ln -s $SECRETS/html/ops/.htpasswd $PROJECT_ROOT/html/ops
