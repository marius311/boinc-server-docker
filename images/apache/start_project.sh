#!/bin/bash

cd $PROJHOME
while [ ! -f .ready ] ; do sleep 1; done
bin/start
(echo "PATH=$PATH"; echo "SHELL=/bin/bash"; cat *.cronjob) | crontab
    
