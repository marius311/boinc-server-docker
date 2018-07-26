#!/bin/bash

set -e

cd /root/boinc/tools

./make_project --url_base 'http://${url_host}' \
                  --project_host '${project}' \
                  --db_host mysql \
                  --db_user root \
                  --no_db \
                  --no_query \
                  --project_root $PROJECT_ROOT \
                  --delete_prev_inst \
                  '${project}'
                  
sed -i -e 's|http://${url_host}|\${url_base}|g' $PROJECT_ROOT/config.xml $PROJECT_ROOT/html/user/schedulers.txt

sed -i -e 's/Deny from all/Require all denied/g' \
          -e 's/Allow from all/Require all granted/g' \
          -e '/Order/d' $PROJECT_ROOT/*.httpd.conf

echo "admin:zJiQQ3OoIfehM" > $PROJECT_ROOT/html/ops/.htpasswd

chmod g+w $PROJECT_ROOT/download
rm -r $PROJECT_ROOT/log_*
mkdir $PROJECT_ROOT/html/stats_archive
