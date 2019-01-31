# BOINC project cookbook (with `boinc-server-docker`)

---
<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [BOINC project cookbook (with `boinc-server-docker`)](#boinc-project-cookbook-with-boinc-server-docker)
	- [Requirements](#requirements)
	- [Docker lightning intro](#docker-lightning-intro)
	- [Launching a test server](#launching-a-test-server)
		- [Server URL](#server-url)
		- [Running jobs](#running-jobs)
			- [Running without `boinc2docker`](#running-without-boinc2docker)
	- [Creating your own project](#creating-your-own-project)
		- [Building and running your server](#building-and-running-your-server)
		- [Pinning the `boinc-server-docker` version](#pinning-the-boinc-server-docker-version)
		- [Installing software](#installing-software)
		- [Custom `config.xml` and other files](#custom-configxml-and-other-files)
		- [Custom configuration variables](#custom-configuration-variables)
			- [Under-the-hood](#under-the-hood)
		- [Managing secrets](#managing-secrets)
			- [Security considerations](#security-considerations)
		- [Advanced steps](#advanced-steps)
			- [Custom `boinc2docker`-based apps](#custom-boinc2docker-based-apps)
			- [Squashing images](#squashing-images)

<!-- /TOC -->
---
This guide will show you how to create your own [BOINC](http://boinc.berkeley.edu/) project with `boinc-server-docker`. 

`boinc-server-docker` packages up all of the dependencies of a BOINC project into a [Docker](http://www.docker.com) application, making it extremely easy and fast to set up. You don't need to know anything about Docker to use `boinc-server-docker`, its fairly easy to pick up the few pieces you need to know along the way. This guide will assume you don't know anything about Docker. 

Once you have your server running, there a few ways to develop and run your code on it. This guide describes only the easiest way to do so, which is to use the `boinc2docker` tool that comes pre-installed on `boinc-server-docker`. This will involve packaging your application code inside a Docker container, a fairly simple task which we will describe. It assumes your code runs on Linux, and will automatically allow your code to run on Linux, Mac, and Windows 64bit volunteer computers. 

`boinc-server-docker` was initially developed for [Cosmology@Home](http://www.cosmologyathome.org). To see an example of a working project which is built on `boinc-server-docker`, see the Cosmology@Home [source code](http://www.github.com/marius311/cosmohome). 

**Note on alternatives**

There are other ways to run a server rather than using `boinc-server-docker`, for example [installing](https://boinc.berkeley.edu/trac/wiki/ServerIntro) the server software yourself, or using the prepackaged [VM image](https://boinc.berkeley.edu/trac/wiki/VmServer). Although these will work, they require more expertise and configuration; `boinc-server-docker` works out of the box and otherwise has no limitations. 


There are other ways to develop your applications too besides `boinc2docker`, for example compiling your code natively for each of the different platforms you wish to support (see e.g. the section [Developing BOINC applications](https://boinc.berkeley.edu/trac/wiki/ProjectMain)).
You might want to do this if your application only compiles on Windows or Mac, or if you need GPU computing (which is currently not supported by `boinc2docker` apps). However, if neither of those are the case, `boinc2docker` applications are likely the easiest and fastest way to run your code (note the speed penalty due to the fact `boinc2docker` runs your code in a virtual machine is only 5-10%). 


## Requirements

If you are hosting your server on a Linux machine, the requirements are,

* [Docker](https://docs.docker.com/engine/installation/) (>=17.03.0ce)
* [docker-compose](https://docs.docker.com/compose/install/) (>=1.13.0 but !=1.19.0 due to a [bug](https://github.com/docker/docker-py/issues/1841))
* git

(Note that Docker requires a 64-bit machine and Linux kernel newer than version 3.10)

If your are hosting your server on Windows/Mac, you should use either,

* [Docker for Mac](https://docs.docker.com/docker-for-mac/install/#download-docker-for-) (>=17.06.0ce)
* [Docker for Windows](https://docs.docker.com/docker-for-windows/install/) (>=17.06.0ce)

If you Windows/Mac system is too old to run either of those, you can use instead, 

* [Docker Toolbox](https://docs.docker.com/toolbox/overview) (>=17.05.0ce)

There are no other dependencies, as everything else is packaged inside of Docker. 

The server itself runs Linux. On Windows/Mac, Docker does the job of transparently virtualizing a Linux machine for you. The commands given in this guide should be run from your system's native terminal, unless you are running Docker Toolbox, in which case they should be run from the "Docker Quickstart Terminal" (and on Windows you will need to add `.exe` to the end, e.g. `docker.exe` instead of `docker`).


## Docker lightning intro

Docker is kind of like a virtual machine in that it packages up a program, its dependencies, and in fact an entire operating system, into a self contained and isolated unit. It's not actually a virtual machine though. For example, it doesn't run any slower than if you were running the programs natively. 

Some terminology: A Docker **image** (like a virtual machine image) contains the operating system and its entire filesystem. Images have names that look like "debian" or "ubuntu:16.04". The part after the ":" specifies the version (the default is "latest", so "debian" and "debian:latest" are the same thing). A running image is called a **container**; you can run multiple containers from a given image (i.e. multiple instances). Unlike most virtual machines, when you stop a container, any changes to files are lost. To persist files between runs, Docker uses **volumes**. A Docker volume is just a folder. It can be mounted at any location inside a container, and it can be mounted in multiple containers at once. Files changed inside volumes are saved. 

Finally, Docker provides a free public repository for hosting images called the Docker Hub. You **pull** and **push** images to and from Docker Hub. This is how we distribute the `boinc-server-docker` images. Most images on the Docker Hub start with a repository name, e.g. our repository is called "boinc" so the full image names look like "boinc/server_apache:latest". 

Docker images are created by writing a **Dockerfile** which specifies a base image to start from and a set of normal Linux commands which are run on top of the image to create a new one. When you create your own server, you will start from a base image provided by `boinc-server-docker` (which already includes all of the BOINC software), and you will write a Dockerfile which adds just your customizations, (e.g. your custom web pages, your applications,  etc...)


## Launching a test server

Before creating your real project, lets launch a sample test server to see how it works. To do this, get the `boinc-server-docker` source code, 

```bash
git clone https://github.com/marius311/boinc-server-docker.git
cd boinc-server-docker
```

and then run,

```bash
docker-compose pull
docker-compose up -d
```

You now have a running BOINC server! 

> *Notes:* 
> * The first time you run this, it may take a few minutes after invoking the `docker-compose up -d` command before the server webpage appears. 
> * Make sure your user is added to the `docker` group, otherwise the `docker-compose` and `docker` commands in this guide need to be run with `sudo`. 
> * If using Docker Toolbox, replace the final command above with `URL_BASE=$(docker-machine ip) docker-compose up -d`. The server will be accessible at the IP returned by `docker-machine ip` rather than at `127.0.0.1`.

The server is made up of three Docker images,

* **boinc/server_mysql** - This runs the MySQL server that holds your project's database. The database files are stored inside a volume called "boincserverdocker_mysql"
* **boinc/server_apache** - This runs the Apache server that serves your project's webpage. It also runs all of the various backend daemons and programs which communicate with hosts that connect to your server.
* **boinc/server_makeproject** - Unlike the other two images, this one doesn't remain running while your server is running. Instead, its run at the beginning to create your project's home folder. Your project's home folder contains things like your web pages, your applications, your job input files, etc... This folder is stored in a volume "boincserverdocker_project" and is mounted into the apache image after its created by this image.

The `docker-compose` program orchestrates Docker applications which involve multiple Docker images (like ours). The configuration and relation between the multiple images can be seen in the file `docker-compose.yml`. 

If you wish to get a shell inside your server (sort of like ssh'ing into it), run `docker-compose exec apache bash`. From here you can run any one-time commands on your server, for example checking the server status (`bin/status`) or submitting some jobs with (`bin/create_work ...`; more on this later). However, remember that only the project folder is a volume, so any changes you make outside of this will disappear the next time you restart the server. In particular, any software installed with `apt-get` will disappear; the correct way to install anything into your server is discussed [later](tbd). 


### Server URL

BOINC servers have their URL hardcoded, and will not function correctly unless they are actually accessible from this URL on the computer your are testing them from. By default, `boinc-server-docker` takes server URL to be `https://127.0.0.1`, i.e. localhost. If you are running Docker natively and testing on your local machine this is the correct URL and you don't need to take any other action. 

If this is not the case, for example if you are running Docker via Docker Machine instead of natively, or if you are running the server remotely, you will have to change the server URL. You can do so with the following command,

```bash
URL_BASE=http://1.2.3.4 docker-compose up -d
```

where you can replace `http://1.2.3.4` with whatever IP address or hostname you want to set for your server. 

Note that each time you run the `docker-compose up` command you should specify the `URL_BASE` otherwise it will reset to the default. If you are running via Docker Machine, you can use `URL_BASE=http://$(docker-machine ip)` to automatically set the correct URL. 

At this point, your BOINC server is now 100% fully functioning, its webpage can be accessed at `http://127.0.0.1/boincserver` or whatever you have set the server URL, and it is ready to accept connections from clients and submission of jobs. 


### Running jobs

Traditionally, creating a BOINC application meant either compiling your code into static binaries for each platform you wanted to support (e.g. 32 and 64-bit Linux, Windows, or Mac), or creating a Virtualbox image housing your app. Instructions for creating these types of applications can be found [here](https://boinc.berkeley.edu/trac/wiki/BasicApi) or [here](https://boinc.berkeley.edu/trac/wiki/VboxApps), and work just the same with `boinc-server-docker`. 

In this guide, however, we describe an easier way to run jobs which uses `boinc2docker`. This tool (which comes preinstalled with `boinc-server-docker`) lets you package your science applications inside Docker containers which are then delivered to your hosts. This makes your code automatically work on Linux, Windows, and Mac, and allows it to have arbitrary dependencies (e.g. Python, etc...) The trade-off is that it only works on 64-bit machines (most of BOINC anyway), requires users to have Virtualbox installed, and does not (currently) support GPUs. 

To begin, we give a brief introduction to running Docker containers in general. The syntax to run a Docker container is `docker run <image> <command>` where `<image>` is the name of the image and `<command>` is a normal Linux shell command to run inside the container. For example, the Docker Hub provides the image `python:alpine` which has Python installed (the "alpine" refers to the fact that the base OS for the Docker image is Alpine Linux, which is super small and makes the entire container be only ~25Mb). Thus you could execute a Python command in this container like, 

```bash
docker run python:alpine python -c "print('Hello BOINC')"
```
and it would print the string "Hello BOINC". 

Suppose you wanted to run this as a BOINC job. To do so, first get a shell inside your server with `docker-compose exec apache bash` and from the project directory run, 

```bash
root@boincserver:~/project$ bin/boinc2docker_create_work.py \
    python:alpine python -c "print('Hello BOINC')"
```

As you see, the script `bin/boinc2docker_create_work.py` takes the same arguments as `docker run` but instead of running the container, it creates a job on your server which runs the container on the volunteer's computer. 

If you now connect a client to your server, it will download and run this job, and you will see "Hello BOINC" in the log file which is returned to the server after the job is finished. 

Note that to run these types of Docker-based jobs, the client computer will need 64bit [Virtualbox](https://www.virtualbox.org/wiki/Downloads) installed and "virtualization" enabled in the BIOS. 

If your jobs have output files, `boinc2docker` provides a special folder for this, `/root/shared/results`; any files written to this directory are automatically tar'ed up and returned as a BOINC result file. For example, if you ran the job, 

```bash
root@boincserver:~/project# bin/boinc2docker_create_work.py \
    python:alpine python -c "open('/root/shared/results/hello.txt','w').write('Hello BOINC')"
```
which creates a file "hello.txt" with contents "Hello BOINC", your server will receive a result file from the client which is a tar containing this file. BOINC results are stored by `boinc-server-docker` in a volume mounted by default at `/results` in the Apache container. 

Of course, the `python:alpine` image here was just an example, any Docker image will work, including ones you create yourself. 

#### Running without `boinc2docker`

Finally, we note that, although by default the test server comes with `boinc2docker` pre-installed, it can also be removed. To do so, set the `TAG` variable to be empty,

```bash
TAG="" docker-compose up -d
```

If you do not specify it, the default tag is `TAG="-b2d"`, which launches the server with `boinc2docker` pre-installed. 


## Creating your own project

Now that you understand the mechanics of how to launch a test server and submit some jobs, lets look at how to actually create your real server. There are two templates for starting a project, 

* **example_project/with_b2d** - this has `boinc2docker` pre-installed, just like the test server 
* **example_project/without_b2d** - if you don't need `boinc2docker`, this image comes without it and is slightly smaller

The first step is to copy one of these two folders to a new folder, which for the purpose of this guide we will call `myproject/` (you can, and should, version control this folder so that you have your project's entire history saved, e.g. like [Cosmology@Home](https://github.com/marius311/cosmohome)). The folder structure will look like this, 

```
myproject/
    docker-compose.yml
    .env
    images/
        apache/
            Dockerfile
        mysql/
            Dockerfile
        makeproject/
            Dockerfile
```

The three `Dockerfile`'s will contain any modifications your project needs on top of the default `boinc-server-docker` images. The `docker-compose.yml` file specifies how these containers work together, and will likely not need any modifications from you. The `.env` file contains some customizable configuration options which you can change. 

### Building and running your server

The test server did not require us to build any Docker containers because these were pre-built, stored on the Docker Hub, and were downloaded to your machine when you executed the `docker-compose pull` command. The images which comprise your server, on the other hand, need to be built; the command to do so is simply `docker-compose build`. 

Afterwards, you can run a `docker-compose up -d` just as before to start the server. Of course, at this point you have made no modifications at all so the server is identical to the test server. We will discuss how to customize your server shortly. Note that you can combine the build and run commands into one with `docker-compose up -d --build`.

To stop your server, run `docker-compose down`. If you wish to reset your server entirely (i.e. to also delete the volumes housing your database and project folder), run `docker-compose down -v`. 


### Pinning the `boinc-server-docker` version

If you open up one of the Dockerfiles for one of the three images comprising your server, for example `myproject/images/apache/Dockerfile`, you will see this:

```Dockerfile
FROM boinc/server_apache:latest-b2d
```

We have not discussed Dockerfile commands yet, but they are fairly simple, and you only need to know about three of them to use `boinc-server-docker`. One of them is the `FROM` command which always comes at the beginning of a Dockerfile and specifies that this image is built starting from another image. In our case it is saying that the Apache image for your server is based on the `boinc-server-docker` image called `boinc/server_apache:latest-b2d`. 

An important step you should take is to replace `latest` with a specific version, for example `2.0.0`, and you should do so for all three Dockerfiles. You can find the latest version of `boinc-server-docker` by looking at the [GitHub releases](https://github.com/marius311/boinc-server-docker/releases). With the versions pinned in this way, you can control exactly when you upgrade the version of `boinc-server-docker` that your server uses, and you can reproducibly go back to any previous version of your server. 


### Installing software

By default the `boinc-server-docker` images come with as few unnecessary programs as possible. Suppose for example you wanted to install `emacs`, which is not included by default. You *could* run `apt-get install emacs` from inside the Apache container, but note that if you now stop and start the container, `emacs` will be gone. This is because files inside Docker containers are not persisted unless they are in a volume. 

The correct way to install software like `emacs` or anything else is to do so in the Dockerfile which builds that image. The Dockerfile for the Apache container is `myproject/images/apache/Dockerfile`, so the correct way to install `emacs` would be to add the following to this file,



```Dockerfile
RUN apt-get update && apt-get install -y emacs
```

`RUN` is another Dockerfile command and simply runs a regular Linux shell command inside our container. We need an `apt-get update` to pull the latest package information and the `-y` flag automatically answers "yes" when `apt-get` asks whether you really want to install the package. If we now run `docker-compose up -d --build`, it will produce a new Apache image for our project and start it up, swapping out the old version (that lacked `emacs`). If you now get a shell inside the container with `docker-compose exec apache bash` you will see that `emacs` is correctly installed, and will still exist if you restart the container. 

In exactly this way you can install any software into any of the containers, or run any commands that might be necessary to set them up. These commands are for the general set up of the server; for things like submitting jobs, performing server maintenance tasks like database optimization, etc... you can just get a shell into the server and run the commands directly from there.

### Custom `config.xml` and other files

Next you will probably want to give your project a name, give it a URL, and more generally copy things into the server and change various files. Lets take a look at changing the project "long name". This is specified inside the `config.xml` file under the tag `<long_name>`. 

If you want to change `config.xml`, first copy it out of the Docker container by running the following from your project folder, 

```bash
docker-compose run makeproject cat config.xml > images/makeproject/config.xml
```

Your folder structure should now look like this,
```
myproject/
    docker-compose.yml
    .env
    images/
        apache/
            Dockerfile
        mysql/
            Dockerfile
        makeproject/
            Dockerfile
            config.xml  # <-- new file we just copied
```

Now edit `images/makeproject/Dockerfile` and add the following line at the bottom,

```Dockerfile
COPY --chown=1000 config.xml $PROJECT_ROOT
```

The `COPY` command makes it so that the next time you `docker-compose build` your project images, the `config.xml` file in `myproject/images/makeproject` is copied into the image, overwriting the default one which is there (the `--chown=1000` part is needed to make the permission correct inside the container). Any changes you make to this file are now reflected in the image, and will take effect after you run `build` and `up`. You can now set `<long_name>` as desired, or change any other option. 

Similarly, you can `COPY` any files into any of the other containers comprising your project. For a full list of available Dockerfile commands beyond the `FROM`, `RUN`, and `COPY` that we've discussed here, see the [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/).


### Custom configuration variables

The server also has a number of custom configuration variables. These fall into two categories, shown below along with their default values:

* Options which can be changed at runtime:
	* `URL_BASE=http://127.0.0.1` - The "base" or "master" URL. 
	* Theses can be specified on the command line:
		```bash
		URL_BASE=http://1.2.3.4 docker-compose up -d
		```
* Options which can only be changed once before the first time you create your project, and cannot be changed afterwards:
	* `PROJECT=boincserver` - The name of the project. 
	* `BOINC_USER=boincadm` - The user running the project
	* `PROJECT_ROOT=/home/boincadm/project` - The project folder.
	* These should be put in your `.env` file before you build your project. 


#### Under-the-hood

You don't really need to know this, but the way these work is the following. For the runtime variables, `boinc-server-docker` does a case-insensitive variable substitution whenever you run `makeproject`, looking for these variables in the following files and also their *filenames*:

```
config.xml
html/user/schedulers.txt
html/project/project.inc
*.httpd.conf
*.readme
*.cronjob
log_*
pid_*
tmp_*
```

You may have noticed, for example, `${url_base}` appears in the `config.xml` from above, and this gets substituted by the run-time value of `URL_BASE`. 

Note that these are not permanent, so that if you later run a `docker-compose up` *without* specifying any of the run-time variables, they reset back to their defaults. Their default values can be set in the `.env`. 

The build-time variables cannot be changed at run-time because they affect the build of the Docker images themselves. In practice this is done with Docker `ONBUILD` instructions and build-args. When you source the base `boinc-server-docker` with your `FROM` command, a number of `ONBUILD` instructions are triggered which finish building the images depending on the args that you have specified. 

### Managing secrets

It is important to understand how the server manages "secrets", such as passwords and signing keys, before launching you real server. 

Your project contains a number of secrets, including: 

* Code signing keys and upload keys
* Ops password
* Database password
* Mail password
* Recaptcha keys

These are collected by `boinc-server-docker` and stored in the `secrets` volume. The first time you create your project, default values are given to all of the passwords, and a new set of keys are generated and stored in this volume. The volume is mounted at `/run/secrets` and you can view the secrets via:

```bash
docker-compose run makeproject bash
cd /run/secrets
ls # etc...
```

Once the `secrets` volume is created, these files are never overwritten unless you manually remove the volume. If you remove the volume, it will be repopulated with the defaults the next time you run `makeproject`. 

Before you launch your real server, you should edit these files to set your own passwords. It is safe to leave the automatically generated signing keys (which are different everytime you build your project). You should also make a backup of this volume in a safe off-site location in case you accidentally delete the volume or suffer a server crash. 

The `DB_PASSWD` variable which you will find in `secrets/secrets.env` controls the database password. The database is created the first time you run the `mysql` container. Changing `DB_PASSWD` does not change the password for the database, only the password which the daemons use to try and log in to the database (which will be wrong if its anything different than was `DB_PASSWD` was set to when you first ran the `mysql` container). Thus, after you set this password, you should delete the `mysql` volume (via `docker volume rm ...`), so that the next time you run your project, the database is generated with the correct password. 


#### Security considerations

One of the secrets stored in the `secrets` volume is the code signing private key. BOINC [recommends](https://boinc.berkeley.edu/trac/wiki/CodeSigning) that this key be kept on an off-site machine without internet connection. `boinc-server-docker` does not currently follow this advice (one reason being that it makes it prohibitively difficult to sign new apps). Instead, we ensure that this key is never stored into any of the Docker images, and is only used at run-time by the `makeproject` container, which never communicates with the outside world. The `apache` container has the `secrets` volume mounted, but has the private key overwritten by mounting the host's `/dev/null` on top of it. The `mysql` container never mounts `secrets`. The possible attack vectors are thus: 

* Gain root access on the host running the server, which would allow the attacker to read the `secrets` volume. The only obvious path would involve an SSH exploit as this should be the only other thing this host is natively running. 

* Gain access to the `www-data` user on the `apache` container, which is the single user communicating with the outside world in any of these containers. Alternatively, gain access to the `mysql` user in the `mysql` container (although this is more difficult as this user never communicates with the outwide world). In either case, *then* perform a Docker breakout exploit to gain access to the root on the host. 

* If running the `b2d` variant of the images, `/var/run/docker.sock` is mounted inside the `apache` container and `boincadm` has permissions on it to control the Docker daemon on the host. Controlling the Docker daemon is equivalent to root access on the host, so the attacker could try and gain access directly to `boincadm` after having comprised `www-data` (there would be no way to gain direct access to `boincadm` as it otherwise never communicates with the outside world). 

Running the server in Docker essentially adds a layer of security, because an attack which before might have given the attacker access to the code signing keys if the server was running natively now needs an additional Docker breakout exploit to be possible. Of course, this is still not as safe as the off-site storage recommendation, but nevertheless requires two difficult exploits, which we view as unlikely to be possible. 


---
*This cookbook is a work in progress; the remainder coming soon!*


### Advanced steps

#### Custom `boinc2docker`-based apps

#### Squashing images
