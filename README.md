
boinc-server-docker
===================

`boinc-server-docker` is the easiest way to run your own [BOINC](http://boinc.berkeley.edu/) server. You can run the server on a Linux machine, in which case the requirements are, 

* [Docker](https://github.com/docker/docker/releases) (>=1.10)
* [docker-compose](https://github.com/docker/compose/releases) (>=1.6.0)
* git 

or you can run it on Windows 7+ or Mac OSX in which case you will need, 

* [Docker Toolbox](https://www.docker.com/products/docker-toolbox)  (>=1.10)

There are no other dependencies, as everything else is packaged inside of Docker. 

Documentation
-------------

For a full tutorial on setting up the server, see the [project cookbook](https://github.com/marius311/boinc-server-docker/blob/master/docs/cookbook.md). 

If you are somewhat familiar with Docker and BOINC, the following short description takes you through creating a server and running your own science application. 

To check out the repository and get a test server fully up and running, simply run,
```bash
git clone https://github.com/marius311/boinc-server-docker.git
cd boinc-server-docker
docker-compose pull
docker-compose up -d
```

Next you will need to point the server url, which is by default `www.boincserver.com`, to your local host IP. This can achieved by adding the line `127.0.0.1 www.boincserver.com` to your `/etc/hosts` file. At this point you can connect a web browser or BOINC client to `www.boincserver.com/boincserver` to see the server web page or run jobs. 

*Windows/Mac:* Instead of `127.0.0.1`, use the IP address reported by the Docker Quickstart Terminal on startup. Additionally, on Windows the file is located at `C:\Windows\system32\drivers\etc\hosts`. 

The server comes pre-configured to immediately run Docker-based science applications. To do so, first create a Docker container which runs your code. As an example, we will use an unmodified `python:alpine` image. Suppose your calculation is run with the following command,

```bash
docker run python:alpine python -c "print('Hello BOINC')"
```

To submit a job on the server which runs this as a BOINC job you would first get a shell inside the server,

```bash
docker exec -it boincserverdocker_apache_1 bash
```

Then submit the job by running 

```bash
bin/boinc2docker_create_work.py python:alpine python -c "print('Hello BOINC')"
```

If your job has output files, have the container write them in `/root/shared/results` and they are automatically returned to the server when the job is done. 

This is a simple example, but any Docker containers with arbitrary code installed inside of them will work! 

Finally, `boinc-server-docker` is not just useful to get a simple test server running, its actually meant to run your real server. To learn how to, read the [project cookbook](https://github.com/marius311/boinc-server-docker/blob/master/docs/cookbook.md), or look at the [Cosmology@Home](https://www.github.com/marius311/cosmohome) source code as an example (`boinc-server-docker` was in fact originally developed for Cosmology@Home). 

Happy crunching! 

Developement and Contributing
-----------------------------

To modify and rebuild any of the `boinc-server-docker` images, you will need this git repository's submodules checked out (run `git submodule update --init --recursive`, or clone with `git clone --recursive` in the first place). Note also that currently building the images only works on Linux. 


Please don't hesitate to get in contact with the maintainers of this project or to submit pull requests!
