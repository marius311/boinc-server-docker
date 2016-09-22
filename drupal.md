# boinc-server-docker (with drupal)

## Requirements

Same as regular boinc-server-docker, just Docker and docker-compose. 

## Instructions

* clone this repo and bring up the server (the build will take a while the first time),

 ```
 docker-compose up -d --build
 ```

* point browser to localhost/install.php

    *if when you access this pae you see an error about the database, wait a few seconds then refresh, its just that it take a moment for the mysql to boot up*

* click on "Install" and go through the install process

* then do remaining configuration with
```
docker-compose exec apache bash
cd /var/www/html/sites/
drush en boincuser
drush vset boinc_root_dir /root/boinc
```

* point browser to http://localhost/admin/boinc/scheduler and set scheduler URL

* other stuff...
