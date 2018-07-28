
# boinc-server-docker

`boinc-server-docker` is the easiest way to run your own [BOINC](http://boinc.berkeley.edu/) server. You can run the server on a Linux machine, in which case the requirements are, 

* [Docker](https://docs.docker.com/engine/installation/) (>=17.03.0ce)
* [docker-compose](https://docs.docker.com/compose/install/) (>=1.13.0 but !=1.19.0 due to a [bug](https://github.com/docker/docker-py/issues/1841))
* git

or you can run your server on Windows 7+ or Mac OSX, in which case you should use either,

* [Docker for Mac](https://docs.docker.com/docker-for-mac/install/#download-docker-for-) (>=17.06.0ce)
* [Docker for Windows](https://docs.docker.com/docker-for-windows/install/) (>=17.06.0ce)

or, if your Windows/Mac system is too old to support either of those,

* [Docker Toolbox](https://docs.docker.com/toolbox/overview) (>=17.05.0ce)

There are no other dependencies, as everything else is packaged inside of Docker. 


## Documentation

For a full tutorial on creating your own server with `boinc-server-docker`, see the [project cookbook](https://github.com/marius311/boinc-server-docker/blob/master/docs/cookbook.md). 

If you would like to set up development environment so that you can contribute to the BOINC server source code, see the [development workflow](docs/dev-workflow.md). 

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


## News

* **Version 3.0.0** - July 27, 2018
    * *Breaking change:* The BOINC daemons no longer run as root, instead they run as an unprivileged user specified by the `BOINC_USER` variable, which is by default equal to `boincadm`. If you created your project with `boinc-server-docker` v2.X.X, you will need to run the following to upgrade your project:

      ```bash
      source .env

      docker-compose run --rm -u root makeproject \
          chown -R $BOINC_USER:$BOINC_USER /home/$BOINC_USER/project.dst

      docker-compose run --rm -u root makeproject mysql -h mysql -e \ """ 
          CREATE USER '$BOINC_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; 
          GRANT ALL ON $PROJECT.* TO $BOINC_USER;"""
      ```
      Alternatively, if don't care about the data in your project folder and database, you can also just wipe the server clean with `docker-compose down -v` and start a new copy with this latest version.
    * A new development workflow is added, mainly aimed at BOINC developers. It makes changing the server code and recompiling / rebuiling a project much quicker. See the [development workflow](docs/dev-workflow.md).

    

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


## Development and Contributing

For using `boinc-server-docker` to work on development of the BOINC server soure code, see the [development workflow](docs/dev-workflow.md). 

There is developer documentation for `boinc-server-docker` itself, but please feel free to contact the maintainers or submit Issues and Pull Requests for this repository. 

As a reminder, to modify and rebuild any of the `boinc-server-docker` images, you will need this git repository's submodules checked out (run `git submodule update --init --recursive`, or clone with `git clone --recursive` in the first place). Note also that currently building the images only works on Linux. 
