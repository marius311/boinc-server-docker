
# boinc-server-docker

[![](https://images.microbadger.com/badges/version/boinc/server_makeproject.svg)](https://microbadger.com/images/boinc/server_makeproject "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/boinc/server_makeproject.svg)](https://microbadger.com/images/boinc/server_makeproject "Get your own image badge on microbadger.com")
![Docker Pulls](https://img.shields.io/docker/pulls/boinc/server_makeproject.svg)
![Docker Stars](https://img.shields.io/docker/stars/boinc/server_makeproject.svg)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/boinc/server_makeproject.svg)

`boinc-server-docker` is the easiest way to run your own [BOINC](http://boinc.berkeley.edu/) server. You can run the server on a Linux machine, in which case the requirements are, 

* [Docker](https://docs.docker.com/engine/installation/) (>=17.09.0ce)
* [docker-compose](https://docs.docker.com/compose/install/) (>=1.17.0 but !=1.19.0 due to a [bug](https://github.com/docker/docker-py/issues/1841))
* git

or you can run your server on Windows 7+ or Mac OSX, in which case you should use either,

* [Docker for Mac](https://docs.docker.com/docker-for-mac/install/#download-docker-for-) (>=17.09.0ce)
* [Docker for Windows](https://docs.docker.com/docker-for-windows/install/) (>=17.09.0ce)

or, if your Windows/Mac system is too old to support either of those,

* [Docker Toolbox](https://docs.docker.com/toolbox/overview) (>=17.09.0ce)

There are no other dependencies, as everything else is packaged inside of Docker. 


## Documentation

For a full tutorial on creating your own server with `boinc-server-docker`, see the [project cookbook](https://github.com/marius311/boinc-server-docker/blob/master/docs/cookbook.md). 

If you are looking to create a server and are already somewhat familiar with Docker and BOINC, the following short description takes you through creating a server and running your own science application. 

### Quickstart

To check out this repository and get a test server fully up and running, simply run,
```bash
git clone https://github.com/marius311/boinc-server-docker.git
cd boinc-server-docker
docker-compose pull
docker-compose up -d
```

You can now visit the server webpage and connect clients to the server at http://127.0.0.1/boincserver. 

> *Notes:* 
> * The first time you run this, it may take a few minutes after invoking the `docker-compose up -d` command before the server webpage appears. 
> * Make sure your user is added to the `docker` group, otherwise the `docker-compose` and `docker` commands in this guide need to be run with `sudo`. 
> * If using Docker Toolbox, replace the final command above with `URL_BASE=$(docker-machine ip) docker-compose up -d`. The server will be accessible at the IP returned by `docker-machine ip` rather than at `127.0.0.1`.

The server comes pre-configured to immediately run Docker-based science applications. To do so, first create a Docker container which runs your code. As an example, we will use a `python:alpine` image. Suppose your calculation is run with the following command,

```bash
docker run python:alpine python -c "print('Hello BOINC')"
```

To submit a job on the server which runs this as a BOINC job you would first get a shell inside the server,

```bash
docker-compose exec apache bash
```

Then submit the job by running 

```bash
bin/boinc2docker_create_work.py python:alpine python -c "print('Hello BOINC')"
```

Now you can connect a BOINC client the server and run this job. Note that to run these types of Docker-based jobs, the client computer will need 64bit [Virtualbox](https://www.virtualbox.org/wiki/Downloads) installed and "virtualization" enabled in the BIOS. 

If your job has output files, have the container write them in `/root/shared/results` and they are automatically returned to the server when the job is done. 

This is a simple example, but any Docker containers with arbitrary code installed inside of them will work! 

To stop the server and delete all server and database files (for example, if you want to start over with a fresh copy), run,

```bash
docker-compose down -v
```


Finally, `boinc-server-docker` is not just useful to get a simple test server running, its actually meant to run your real server. To learn how to, read the [project cookbook](https://github.com/marius311/boinc-server-docker/blob/master/docs/cookbook.md), or look at the [Cosmology@Home](https://www.github.com/marius311/cosmohome) source code as an example (`boinc-server-docker` was in fact originally developed for Cosmology@Home). 

Happy crunching! 

### Development and Contributing

If you wish to modify and rebuild any of the `boinc-server-docker` images yourself, you will need this git repository's submodules checked out. To do so, run `git submodule update --init --recursive` from the repository folder, or clone with `git clone --recursive` in the first place. Note that building these images is only necessary if you are helping with development of this package; if you wish to build your own project _using_ these base images, follow the instruction in the [cookbook](docs/cookbook.md#creating-your-own-project) instead. 

Currently, building the images is only guaranteed to work on Linux. Some users have reported successfully building on Windows or Mac, but this is considered experimental at this point. 

Please feel free to contact the maintainers or submit Issues and Pull Requests for this repository if you wish to contribute! 


## News

* **Version 4.1.0** - Oct 20, 2019
    * Based on [server_release/1.2/1.2](https://github.com/BOINC/boinc/releases/tag/server_release%2F1.2%2F1.2.0).
* **Version 4.0.2** - Apr 27, 2019
    * Based on [server_release/1.0/1.0.4](https://github.com/BOINC/boinc/releases/tag/server_release%2F1.0%2F1.0.4).
* **Version 4.0.1** - Jan 31, 2018
    * Fix problem with mysql image-tagging which caused errors when trying to build a custom project.
* **Version 4.0.0** - Jan 18, 2018
    * Based on [server_release/1.0/1.0.3](https://github.com/BOINC/boinc/releases/tag/server_release%2F1.0%2F1.0.3).
* **Version 3.0.1** - Aug 2, 2018
    * Minor bug fix where `PROJECT_ROOT` wasn't fully customizable
* **Version 3.0.0** - July 27, 2018
    * Based on [server_release/0.9](https://github.com/BOINC/boinc/releases/tag/server_release%2F0.9).
    * Upgraded to Debian Stretch, PHP 7.0.31 and MariaDB 10.3.8. 
    * Docker requirement is now 17.09.0ce on all platforms.  
    * Project "secrets" such as passwords and signing keys are now stored in a new volume called `secrets`, and the procedure for how to deal with them is documented [here](docs/cookbook.md#managing-secrets). 
    * *Breaking change:* For improved security, the BOINC daemons no longer run as root, instead they run as an unprivileged user, by default named `boincadm`. 
    * Added two new options which are configurable at build-time, `BOINC_USER` and `PROJECT_ROOT`, and fixed `PROJECT` which wasn't fully configurable before. Under the hood, the `boinc-server-docker` images now use Docker `ONBUILD` instructions to make this happen.     
    * *Upgrade instructions:* If you don't care about the files in your project's database and project folder, you can just wipe your project clean with `docker-compose down -v` and simply start a fresh server with version `3.0.0`. If instead you want to upgrade a project you created with `boinc-server-docker v2.x.x`, you should follow these instructions:
        1) Edit the `FROM` line in your custom Dockerfiles to source the appropriate `3.0.0` images.
        2) Diff your `docker-compose.yml` and `.env` files against the corresponding ones in `example_project/`, and merge in changes you see (notably, add the `secrets` volume). 
        3) Run `docker-compose build` to build updated images. 
        3) Run `docker-compose run --rm makeproject bash` and navigate to `/home/boincadm/secrets`. This is your `secrets` volume, and you should edit the files you see here so that they contain your passwords, keys, etc... 
        4) Bring your project down with `docker-compose down`.
        5) Run the following to update permissions and upgrade your database: 

              ```bash
              source .env
              eval "$(docker-compose run --rm -T makeproject cat /run/secrets/secrets.env)"
              
              docker-compose run --rm -u root makeproject chown -R $BOINC_USER:$BOINC_USER $PROJECT_ROOT.dst

              docker-compose exec mysql mysql_upgrade

              docker-compose exec mysql mysqladmin -u root password $DB_PASSWD
              ```
        6) Now bring your project back up with `docker-compose up -d`.

* **Version 2.1.0** - May 29, 2018
    * Update boinc to [server_release/0.9](https://github.com/BOINC/boinc/releases/tag/server_release%2F0.9).
* **Version 2.0.0** - Feb 27, 2018
    * *New feature:* The server URL and project name can now be changed at run-time with e.g.: `URL_BASE=http//1.2.3.4 PROJECT=myproject docker-compose up -d`. See [here](docs/cookbook.md#server-url) and [here](docs/cookbook.md#custom-configuration-variables) in the Project Cookbook for more details.
    * *Breaking change:* The `$PROJHOME` variable which was previously available in `apache` and `makeproject` containers has been renamed to `$PROJECT_ROOT` to be consistent with the `make_tools` script, similarly as with `URL_BASE` and `PROJECT`, and in anticipation that it too will become configurable.
    * Upgraded version requirements.
* **Version 1.4.1** - July 26, 2017
    * The default server URL is now `http://127.0.0.1/boincserver` rather than previously when it was `http://boincserver.com/boincserver`. This removes the need to edit your `/etc/hosts` file on Linux, and on Windows/Mac/docker-machine replaces having to edit `/etc/hosts` with the SSH tunnel command above. *Related warning: the boincserver.com domain is currently being squatted, so if you're using the old version be careful that you do not type sensitive information into the server website thinking you're interacting with your local test server when in fact it's a remote server at the squatted domain.*
    * Updated docker-compose requirement from 1.6.0 to 1.7.0, and on Windows/Mac, updated Docker Toolbox requirement from 1.10.0 to 1.11.0
    * A number of improvements to boinc2docker (see [ccfe9a9](https://github.com/marius311/boinc-server-docker/commit/ccfe9a9704b9282f528565c74e07ee3be698aa0d)).
