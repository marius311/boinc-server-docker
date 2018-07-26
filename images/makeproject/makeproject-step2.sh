#!/bin/bash

set -e

PROJECT_ROOT_DEST=$PROJECT_ROOT.dst

echo "Updating project files in data volume..."
cd $PROJECT_ROOT
# do variable substitution in files
for file in config.xml html/user/schedulers.txt *.httpd.conf; do 
    sed -i -e "s|\${PROJECT}|$PROJECT|gI" \
           -e "s|\${URL_BASE}|$URL_BASE|gI" \
        $file
done
# do variable substitution in file names (although with -n to not overwrite
# existing files which may be customized versions provided by the project)
for file in \$\{project\}*; do
    mv -n $file ${file/\$\{project\}/$PROJECT}
done
# clean up old files with PROJECT-dependent names
find $PROJECT_ROOT_DEST -maxdepth 1 -regextype egrep \
    -regex "(.*(cronjob|readme|(httpd.conf)))|(.*/(log|pid|tmp).*)|(.*/run_state.*xml)" \
    ! -regex "(.*/$PROJECT.(cronjob|readme|(httpd.conf)))|(.*/(log|pid|tmp)_$PROJECT)|(.*/run_state_${PROJECT}.xml)" \
    -exec rm -rf {} \;
# copy files
cp -rfT --preserve=mode,ownership $PROJECT_ROOT $PROJECT_ROOT_DEST
mv $PROJECT_ROOT ${PROJECT_ROOT}.orig
ln -s $PROJECT_ROOT_DEST $PROJECT_ROOT
cd $PROJECT_ROOT


# wait for MySQL server to start
echo "Waiting for MySQL server to start..."
if ! timeout -s KILL 60 mysqladmin ping -h mysql --wait &> /dev/null ; then
    echo "MySQL server failed to start after 60 seconds. Aborting."
    exit 1
fi

# create database if it doesn't exist
if [[ -z $(mysql -h mysql -e "show databases like '$PROJECT'") ]]; then
    echo "Creating database..."
    PYTHONPATH=/root/boinc/py python -c """
from Boinc import database, configxml
database.create_database(srcdir='/root/boinc',
                         config=configxml.ConfigFile(filename='${PROJECT_ROOT}/config.xml').read().config,
                         drop_first=False)
    """
fi

(cd html/ops && ./db_schemaversion.php > ${PROJECT_ROOT}/db_revision)

bin/xadd
yes | bin/update_versions

touch $PROJECT_ROOT/.built_${PROJECT}
