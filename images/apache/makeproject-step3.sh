#!/bin/bash

set -e

cd $PROJECT_ROOT

# gives $BOINC_USER permission to run Docker commands
DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
addgroup -gid ${DOCKER_GID} docker
addgroup ${BOINC_USER} docker

while :
do

    # the first time we build a project, we wait here until the makeproject-step2.sh
    # script is done
    while [ ! -f .built_${PROJECT} ] ; do sleep 1; done

    echo "Finalizing project startup..."
    
    ln -sf ${PROJECT_ROOT}/${PROJECT}.httpd.conf /etc/apache2/sites-enabled/
    
    # if apache already booted up, restart it so as to reread the httpd.conf
    # file (it could be close as both this script and apache are started at
    # the same time by supervisord, but we need this just in case)
    if ps -C apache2 ; then
        apache2ctl -k graceful
    fi
    
    # start daemons as $BOINC_USER
    su $BOINC_USER -c """
        bin/start
        (echo "PATH=$PATH"; echo "SHELL=/bin/bash"; cat *.cronjob) | crontab
    """
    
    echo "Project startup complete."
    
    # subsequent times we build a project (such as after a PROJECT change), we
    # go through once then possibly go through again to avoid a race condition
    # with makeproject-step2.sh
    inotifywait -e attrib .built_${PROJECT}
done
    
