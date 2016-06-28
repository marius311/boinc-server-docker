#!/usr/bin/env python

import os
from os import system as _sh
import os.path as osp
from os.path import join, basename
import sys
from time import sleep
import _mysql_exceptions
from glob import glob
from functools import partial

sys.path.append('/root/boinc/py')
import boinc_path_config
from Boinc import database, configxml

sh = partial(lambda s,l: _sh(s.format(**l)),l=locals())

PROJHOME=os.environ['PROJHOME']
PROJHOME_DST=PROJHOME+'.dst'


print "Copying project files to data volume..."
for f in glob(join(PROJHOME,'*'))+glob(join(PROJHOME,'.*')): 
    sh('cp -rp "{f}" {PROJHOME_DST}')
sh('rm -rf {PROJHOME}; ln -s {PROJHOME_DST} {PROJHOME}')


if not '--copy-only' in sys.argv:
    
    print "Creating database..."
    waited=False
    while True:
        try:
            database.create_database(srcdir='/root/boinc', 
                                     config=configxml.ConfigFile(filename=join(PROJHOME,'config.xml')).read().config, 
                                     drop_first=False)
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
            sh('cd {PROJHOME}/html/ops; ./db_schemaversion.php > {PROJHOME}/db_revision')
            break
    if waited: sys.stdout.write('\n')


    print "Running BOINC update scripts..."
    os.chdir(PROJHOME)
    sh('bin/xadd')
    sh('(%s) | bin/update_versions'%('; '.join(['echo y']*10)))
    
sh('touch {PROJHOME}/.ready')
