#!/usr/bin/env python

import os
from os import system as sh
import os.path as osp
import sys
from time import sleep
import _mysql_exceptions

sys.path.append('/root/boinc/py')
import boinc_path_config
from Boinc import database, configxml



print "Copying project files to data volume..."
sh('cp -r /root/projects.build/boincserver /root/projects')
for x in ['html', 'html/cache', 'upload', 'log_boincserver']: 
    sh('chmod -R g+w /root/projects/boincserver/'+x)


if not '--copy-only' in sys.argv:
    
    print "Creating database..."
    waited=False
    while True:
        try:
            database.create_database(
                srcdir = '/root/boinc',
                config = configxml.ConfigFile(filename='/root/projects/boincserver/config.xml').read().config,
                drop_first = False
            )
        except _mysql_exceptions.ProgrammingError as e:
            if e[0]==1007: 
                print "Database exists, not overwriting."
                break
            else:
                raise
        except _mysql_exceptions.OperationalError as e:
            if e[0]==2003:  
                if waited: sys.stdout.write('.'); sys.stdout.flush()
                else: 
                    sys.stdout.write("Waiting for mysql server to be up..."); sys.stdout.flush()
                    waited=True
                sleep(1)
            else: 
                raise
        else:
            sh('cd /root/projects/boincserver/html/ops; ./db_schemaversion.php > /root/projects/boincserver/db_revision')
            break
    if waited: sys.stdout.write('\n')


    print "Running BOINC update scripts..."
    os.chdir('/root/projects/boincserver')
    sh('bin/xadd')
    sh('(%s) | bin/update_versions'%('; '.join(['echo y']*10)))
