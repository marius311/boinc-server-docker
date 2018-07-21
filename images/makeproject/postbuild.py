#!/usr/bin/env python

import os
from os import chdir, system as _sh
import os.path as osp
from os.path import join, basename, exists
import sys
from time import sleep
import _mysql_exceptions
from glob import glob
from functools import partial

sys.path.append('/usr/local/boinc/software/py')
import boinc_path_config
from Boinc import database, configxml

sh = partial(lambda s,l: _sh(s.format(**l)),l=locals())

PROJHOME=os.environ['PROJHOME']
PROJHOME_DST=PROJHOME+'.dst'
URL_BASE=join(os.environ['URL_BASE'],'')


print "Updating project files in data volume..."
for f in glob(join(PROJHOME,'*'))+glob(join(PROJHOME,'.*')): 
    sh('cp -rpf "{f}" {PROJHOME_DST}')
sh('rm -rf {PROJHOME}; ln -s {PROJHOME_DST} {PROJHOME}')


print "Setting project URL to: "+URL_BASE
for filename in ["config.xml","html/user/schedulers.txt","boincserver.readme"]:
    filepath = join(PROJHOME,filename)
    if exists(filepath):
        with open(filepath,"r") as f: contents = f.read()
        with open(filepath,"w") as f: f.write(contents.replace("http://url_base/",URL_BASE))


if not '--copy-only' in sys.argv:
    
    print "Creating database..."
    waited=False
    while True:
        try:
            database.create_database(srcdir='/usr/local/boinc/software', 
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
            chdir(join(PROJHOME,"html/ops"))
            sh('./db_schemaversion.php > {PROJHOME}/db_revision')
            break
    if waited: sys.stdout.write('\n')


    print "Running BOINC update scripts..."
    chdir(PROJHOME)
    sh('bin/xadd')
    sh('(%s) | bin/update_versions'%('; '.join(['echo y']*10)))
    
sh('touch {PROJHOME}/.ready')
