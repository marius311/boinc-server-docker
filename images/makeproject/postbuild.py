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

PROJHOME=os.environ['PROJHOME']
PROJHOME_DST=PROJHOME+'.dst'

print "Copying project files to data volume..."
sh('cp -r {src}/* {dst}'.format(src=PROJHOME,dst=PROJHOME_DST))
for x in ['html', 'html/cache', 'upload', 'log_boincserver']: 
    sh('chmod -R g+w '+osp.join(PROJHOME_DST,x))


if not '--copy-only' in sys.argv:
    
    print "Creating database..."
    waited=False
    while True:
        try:
            database.create_database(
                srcdir = '/root/boinc',
                config = configxml.ConfigFile(filename=osp.join(PROJHOME_DST,'config.xml')).read().config,
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
                    sys.stdout.write("Waiting for mysql server to start..."); sys.stdout.flush()
                    waited=True
                sleep(1)
            else: 
                raise
        else:
            sh('cd {PROJHOME}/html/ops; ./db_schemaversion.php > {PROJHOME}/db_revision'.format(PROJHOME=PROJHOME_DST))
            break
    if waited: sys.stdout.write('\n')


    print "Running BOINC update scripts..."
    os.chdir(PROJHOME_DST)
    sh('bin/xadd')
    sh('(%s) | bin/update_versions'%('; '.join(['echo y']*10)))
