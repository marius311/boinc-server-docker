# BOINC project cookbook (with `boinc-server-docker`)

This guide will explain how to create your own BOINC project using `boinc-server-docker`. This is the easiest way to create and run your own project (while there are other options, e.g. [installing](https://boinc.berkeley.edu/trac/wiki/ServerIntro) the server software yourself, or using the prepackaged [VM image](https://boinc.berkeley.edu/trac/wiki/VmServer), they are more difficult and require more configuration; `boinc-server-docker` works out of the box). 

`boinc-server-docker` packages up all of the dependencies of a BOINC project into a [Docker](http://www.docker.com) application. You don't need to know anything about Docker to use `boinc-server-docker`, its fairly easy to pick up the few pieces you need to know along the way. This guide will assume you don't know anything about Docker. 

Once you have your server running, there a few ways to develop and run applications on it. There are several traditional ways to do so, for example, creating platform specific binaries (which will *not* be described in this guide; instead see e.g. the section [Developing BOINC applications](https://boinc.berkeley.edu/trac/wiki/ProjectMain)). Alternatively, there is an easier way which uses `boinc2docker`. This tool (which comes preinstalled with `boinc-server-docker`) lets you package your science applications inside Docker containers which are then delivered to your hosts. This makes your code automatically work on Linux, Windows, and Mac, and allows it to have arbitrary dependencies (e.g. Python, etc...) 

`boinc-server-docker` was initially developed for [Cosmology@Home](www.cosmologyathome.org). To see an example of a working project which is built on `boinc-server-docker`, see the Cosmology@Home [source code](www.github.com/marius311/cosmohome). 


## Requirements

The computer hosting your server must run Linux. Additionally it needs the following software:

* [Docker](https://docs.docker.com/engine/installation/) (>=1.10)
* [docker-compose](https://docs.docker.com/compose/install/) (>=1.6)
* git
* make

There are no other dependencies, as everything else is packaged inside of Docker.

*TODO: It should work OK on Mac/Windows too via docker-machine, but this needs to be tested/documented. Eventually the native hypervisor support will make it even easier.*

### Installing Docker

Since this guide assumes you don't know about Docker, we will give instructions how to install it. 

TODO. 


## Docker lightning intro

Docker is kind of like a virtual machine in that it packages up a program, its dependencies, and in fact an entire operating system, into a self contained and isolated unit. It's not actually a virtual machine though. For example, it doesn't run any slower than if you were running the programs natively. 

Some terminology: A Docker **image** (like a virtual machine image) contains the operating system and its entire filesystem. Images have names that look like "debian" or "ubuntu:16.04". The part after the ":" specifies the version (the default is "latest", so "debian" and "debian:latest" are the same thing). A running image is called a **container**; you can run multiple containers from a given image (i.e. multiple instances). Unlike most virtual machines, when you stop a container, any changes to files are lost. To persist files between runs, Docker uses **volumes**. A Docker volume is just a folder. It can be mounted at any location inside a container, and it can be mounted in multiple containers at once. Files changed inside volumes are saved. 

Finally, Docker provides a free public repository for hosting images called the Docker Hub. You **pull** and **push** images to and from Docker Hub. This is how we distribute the `boinc-server-docker` images. Most images on the Docker Hub start with a repository name, e.g. our repository is called "boinc" so the full image names look like "boinc/server_apache:latest". 

Docker images are created by writing a **Dockerfile** which specifies a base image to start from and a set of normal Linux commands which are run ontop of the image to create a new one. When you create your own server, you will start from a base image provided by `boinc-server-docker` (which already includes all of the BOINC software), and you will write a Dockerfile which adds just your customizations, (e.g. your custom web pages, your applications,  etc...)


## Launching a test server

Before creating your real project, lets launch a sample test server to see how it works. To do this, get the `boinc-server-docker` source code, 

```bash
git clone https://github.com/marius311/boinc-server-docker.git
cd boinc-server-docker
```

and then run,

```bash
make pull
make up
```

You now have a running BOINC server!  (*Note:* the `make pull` step downloads about ~1GB of data so it may take a while)

The server is made up of three Docker images,

* **boinc/server_mysql** - This runs the MySQL server that holds your project's database. The database files are stored inside a volume called "boincserverdocker_mysql"
* **boinc/server_apache** - This runs the Apache server that serves your project's webpage. It also runs all of the various backend daemons and programs which communicate with hosts that connect to your server.
* **boinc/server_makeproject** - Unlike the other two images, this one doesn't remain running while your server is running. Instead, its run at the beginning to create your project's home folder. Your project's home folder contains things like your web pages, your applications, your job input files, etc... This folder is stored in a volume "boincserverdocker_project" and is mounted into the apache image after its created here.

The `Makefile` contains various convenience methods to start and stop these containers. For example, `make rm-apache` will stop the apache container, or `make up-mysql` will start the mysql container (if it wasn't already running). If you read the `Makefile`, you'll see these all involve short calls to the program `docker-compose`. This program orchestrates Docker applications which involve multiple Docker images, like ours. The configuration and relation between the multiple images is given in the file `docker-compose.yml`. 

If you wish to get a shell inside your server (sort of like ssh'ing into it), run `make exec-apache`. From here you can run any one-off commands on your server, for example checking the server status (`bin/status`) or submitting some jobs with (`bin/create_work ...`; more on this later). However, remember that only the project folder is a volume, so any changes you make outside of this will dissapear the next time you restart the apache container. In particular, any software installed with `apt-get` will dissapear; the correct way to install anything into your server is discussed [later](tbd). 

#### Accessing the webpage / connecting a client

Docker maps the apache container's port 80 (where the webpage is being served) to port 80 on the machine where the container is running. To see the server webpage, point a web-browser to this machine's IP address. If you are running locally, e.g. on your laptop, this will be `127.0.0.1`. If you are running on a remote server, this will be the server's IP address or domain name. 

One detail that makes things slightly more complicated is that BOINC servers have their URL hardcoded. For example, the URL for our test server is by default `www.boincserver.com`. If, on the computer which we are trying to access the server from, the domain name `www.boincserver.com` doesn't resolve to the IP address where the apache container is actually running, *the server will not function correctly.* 

On Linux, you can forward the domain name to the appropriate IP address by editing the file `/etc/hosts` and adding the line, 

```
127.0.0.1   www.boincserver.com
```

(or with `127.0.0.1` replaced by the IP address of the remote server which is running your containers). 

With this change made, your BOINC server is now 100% fully functioning, its webpage can be accessed at `www.boincserver.com/boincserver`, and it is ready to accept connections from clients and submission of jobs. 


### Running jobs

Traditionally, creating a BOINC application meant either compiling your code into static binaries for each platform you wanted to support (e.g. 32 and 64-bit Linux, Windows, or Mac), or creating a Virtualbox image housing your app. Instructions for creating these types of applications can be found [here](https://boinc.berkeley.edu/trac/wiki/BasicApi) or [here](https://boinc.berkeley.edu/trac/wiki/VboxApps), and work just the same with `boinc-server-docker`. 

In this guide, however, we describe an easier way to run jobs which uses `boinc2docker`. This tool (which comes preinstalled with `boinc-server-docker`) lets you package your science applications inside Docker containers which are then delivered to your hosts. This makes your code automatically work on Linux, Windows, and Mac, and allows it to have arbitrary dependencies (e.g. Python, etc...) The trade-off is that it only works on 64-bit machines (most of BOINC anyway), requires users to have Virtualbox installed, and does not (currently) support GPUs. 

To begin, we give a brief introduction to running Docker containers in general. The syntax to run a Docker container is `docker run <image> <command>` where `<image>` is the name of the image and `<command>` is a normal Linux shell command to run inside the container. For example, the Docker Hub provides the image `python:alpine` which has Python installed (the "alpine" refers to the fact that the base OS for the Docker image is Alpine Linux, which is super small and makes the entire container be only ~25Mb). Thus you could execute a Python command in this container like, 

```bash
docker run python:alpine python -c "print('Hello BOINC')"
```
and it would print the string "Hello BOINC". 

Suppose you wanted to run this as a BOINC job. To do so, first get a shell inside your server with `make exec-apache` and from the project directory run, 

```bash
root@boincserver:~/project# bin/boinc2docker_create_work.py \
    python:alpine python -c "print('Hello BOINC')"
```

Like you see, the script `bin/boinc2docker_create_work.py` takes the same arguments as `docker run` but instead of running the container, it creates a job on your server which runs the container on the volunteer's computer. 

If you now connect a client to your server, it will download and run this job, and you will see "Hello BOINC" in the log file which is returned to the server after the job is finished. If your jobs have output files, `boinc2docker` provides a special folder for this, `/root/shared/results`; any files written to this directory are automatically tar'ed up and returned as a BOINC result file. For example, if you ran the job, 

```bash
root@boincserver:~/project# bin/boinc2docker_create_work.py \
    python:alpine python -c "open('/root/shared/results/hello.txt','w').write('Hello BOINC')"
```
which creates a file "hello.txt" with contents "Hello BOINC", your server will receive a result file from the client which is a tar containing this file. BOINC results are stored by `boinc-server-docker` in a volume mounted by default at `/results` in the Apache container. 

Of course, the `python:alpine` image here was just an example, any Docker image will work, including ones you create yourself. 


## Creating your own project

Now that you understand the mechanics of how to launch a test server and submit some jobs, lets look at how to actually create your real server. There are two templates for starting a project, 

* **example_project/with_b2d** - this has `boinc2docker` pre-installed, just like the test server 
* **example_project/without_b2d** - if you don't need `boinc2docker`, this image comes without it and is slightly smaller

The first step is to copy one of these two folders to a new folder, which for the purpose of this guide we will call `myproject/` (you can, and should, version control this folder so that you have your project's entire history saved, e.g. like at [Cosmology@Home](https://github.com/marius311/cosmohome)). The folder structure will look like this, 

```
myproject/
    docker-compose.yml
    images/
        apache/
            Dockerfile
        mysql/
            Dockerfile
        makeproject/
            Dockerfile
```

The three `Dockerfile`'s will contain any modifications your project needs ontop of the default `boinc-server-docker` images. The `docker-compose.yml` file specifies how these containers work together, and will likely not need any modifications from you. 

### Required steps

#### Pinning the `boinc-server-docker` version

#### Custom `config.xml` and webpages

#### Digitally signing your apps


### Typical steps

#### Custom server scripts and dependencies

#### Custom `boinc2docker`-based apps



