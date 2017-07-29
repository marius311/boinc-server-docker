
boinc-server-docker
===================

`boinc-server-docker` is the easiest way to run your own [BOINC](http://boinc.berkeley.edu/) server. You can run the server on a Linux machine, in which case the requirements are, 

* [Docker](https://github.com/docker/docker/releases) (>=1.10)
* [docker-compose](https://github.com/docker/compose/releases) (>=1.7.0)
* git 

or you can run it on Windows 7+ or Mac OSX in which case you will need, 

* [Docker Toolbox](https://www.docker.com/products/docker-toolbox)  (>=1.11)

There are no other dependencies, as everything else is packaged inside of Docker. 

Documentation
-------------

For a full tutorial on setting up the server, see the [project cookbook](https://github.com/marius311/boinc-server-docker/blob/master/docs/cookbook.md). 

If you are somewhat familiar with Docker and BOINC, the following short description takes you through creating a server and running your own science application. 

To check out this repository and get a test server fully up and running, simply run,
```bash
git clone https://github.com/marius311/boinc-server-docker.git
cd boinc-server-docker
docker-compose pull
docker-compose up -d
```

On Windows, Mac, or Linux if running Docker via docker-machine instead of natively, you will also need to run `ssh docker@$(docker-machine ip) -L 80:localhost:80 -N` and enter `tcuser` when prompted for a password (on Mac/Linux, this command needs to be run with `sudo`).

You can now visit the server webpage and connect clients to the server at  http://127.0.0.1/boincserver. 

The server comes pre-configured to immediately run Docker-based science applications. To do so, first create a Docker container which runs your code. As an example, we will use an unmodified `python:alpine` image. Suppose your calculation is run with the following command,

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

If your job has output files, have the container write them in `/root/shared/results` and they are automatically returned to the server when the job is done. 

This is a simple example, but any Docker containers with arbitrary code installed inside of them will work! 

To stop the server and delete all server and database files (for example, if you want to start over with a fresh copy), run,

```
docker-compose down -v
```


Finally, `boinc-server-docker` is not just useful to get a simple test server running, its actually meant to run your real server. To learn how to, read the [project cookbook](https://github.com/marius311/boinc-server-docker/blob/master/docs/cookbook.md), or look at the [Cosmology@Home](https://www.github.com/marius311/cosmohome) source code as an example (`boinc-server-docker` was in fact originally developed for Cosmology@Home). 

Happy crunching! 


News
----

* **Version 1.4.1** - July 26, 2017
    * The default server URL is now `http://127.0.0.1/boincserver` rather than previously when it was `http://boincserver.com/boincserver`. This removes the need to edit your `/etc/hosts` file on Linux, and on Windows/Mac/docker-machine replaces having to edit `/etc/hosts` with the SSH tunnel command above. *Related warning: the boincserver.com domain is currently being squatted, so if you're using the old version be careful that you do not type sensitive information into the server website thinking you're interacting with your local test server when in fact it's a remote server at the squatted domain.*
    * Updated docker-compose requirement from 1.6.0 to 1.7.0, and on Windows/Mac, updated Docker Toolbox requirement from 1.10.0 to 1.11.0
    * A number of improvements to boinc2docker (see [ccfe9a9](https://github.com/marius311/boinc-server-docker/commit/ccfe9a9704b9282f528565c74e07ee3be698aa0d)).


Development and Contributing
-----------------------------

To modify and rebuild any of the `boinc-server-docker` images, you will need this git repository's submodules checked out (run `git submodule update --init --recursive`, or clone with `git clone --recursive` in the first place). Note also that currently building the images only works on Linux. 


Please don't hesitate to get in contact with the maintainers of this project or to submit pull requests!
