# BOINC project cookbook (with `boinc-server-docker`)

This guide will show you how to create your own [BOINC](http://boinc.berkeley.edu/) project with `boinc-server-docker`. 

`boinc-server-docker` packages up all of the dependencies of a BOINC project into a [Docker](http://www.docker.com) application, making it extremely easy and fast to set up. You don't need to know anything about Docker to use `boinc-server-docker`, its fairly easy to pick up the few pieces you need to know along the way. This guide will assume you don't know anything about Docker. 

Once you have your server running, there a few ways to develop and run your code on it. This guide describes only the easiest way to do so, which is to use the `boinc2docker` tool that comes preinstalled on `boinc-server-docker`. This will involve packaging your application code inside a Docker container, a fairly simple task which we will describe. It assumes your code runs on Linux, and will automatically allow your code to run on Linux, Mac, and Windows 64bit volunteer computers. 

`boinc-server-docker` was initially developed for [Cosmology@Home](www.cosmologyathome.org). To see an example of a working project which is built on `boinc-server-docker`, see the Cosmology@Home [source code](www.github.com/marius311/cosmohome). 

### Note on alternatives

There are other ways to run a server rather than using `boinc-server-docker`, for example [installing](https://boinc.berkeley.edu/trac/wiki/ServerIntro) the server software yourself, or using the prepackaged [VM image](https://boinc.berkeley.edu/trac/wiki/VmServer). Although these will work, they require more expertise and configuration; `boinc-server-docker` works out of the box and otherwise has no limitations. 


There are other ways to develop your applications too besides `boinc2docker`, for example compiling your code natively for each of the different platforms you wish to support (see e.g. the section [Developing BOINC applications](https://boinc.berkeley.edu/trac/wiki/ProjectMain)).
You might want to do this if your application only compiles on Windows or Mac, or if you need GPU computing (which is currently not supported by `boinc2docker` apps). However, if neither of those are the case, `boinc2docker` applications are likely the easiest and fastest way to run your code (note the speed penalty due to the fact `boinc2docker` runs your code in a virtual machine is only 5-10%). 


## Requirements

If you are hosting your server on a Linux machine, the requirements are,

* [Docker](https://docs.docker.com/engine/installation/) (>=1.10)
* [docker-compose](https://docs.docker.com/compose/install/) (>=1.7)
* git

(Note that Docker requires a Linux kernel newer than version 3.10)

If you are hosting your server on Windows/Mac, the requirements are,

* [Docker Toolbox](https://www.docker.com/products/docker-toolbox)  (>=1.11)

There are no other dependencies, as everything else is packaged inside of Docker. 

The server itself runs Linux. On Windows/Mac, Docker Toolbox does the job of transparently virtualizing a Linux machine to run the server and configuring the networking properly. The commands given in this guide are Linux commands which, if you are running on Window/Mac, should be run from the "Docker Quickstart Terminal" (and on Windows you will need to add `.exe` to the end, e.g. `docker.exe` instead of `docker`).


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
docker-compose pull
docker-compose up -d
```

You now have a running BOINC server!  (*Note:* the first time you run this about ~1GB of data will be downloaded as the `boinc-server-docker` images are pulled from the Docker Hub)

The server is made up of three Docker images,

* **boinc/server_mysql** - This runs the MySQL server that holds your project's database. The database files are stored inside a volume called "boincserverdocker_mysql"
* **boinc/server_apache** - This runs the Apache server that serves your project's webpage. It also runs all of the various backend daemons and programs which communicate with hosts that connect to your server.
* **boinc/server_makeproject** - Unlike the other two images, this one doesn't remain running while your server is running. Instead, its run at the beginning to create your project's home folder. Your project's home folder contains things like your web pages, your applications, your job input files, etc... This folder is stored in a volume "boincserverdocker_project" and is mounted into the apache image after its created by this image.

The `docker-compose` program orchestrates Docker applications which involve multiple Docker images (like ours). The configuration and relation between the multiple images can be seen in the file `docker-compose.yml`. 

If you wish to get a shell inside your server (sort of like ssh'ing into it), run `docker exec -it boincserverdocker_apache_1 bash`. From here you can run any one-time commands on your server, for example checking the server status (`bin/status`) or submitting some jobs with (`bin/create_work ...`; more on this later). However, remember that only the project folder is a volume, so any changes you make outside of this will disappear the next time you restart the server. In particular, any software installed with `apt-get` will disappear; the correct way to install anything into your server is discussed [later](tbd). 

#### Accessing the webpage / connecting a client

BOINC servers have their URL hardcoded, and will not function correctly unless they are actually accessible from this URL on the comuter your are testing them from. By default, `boinc-server-docker` takes server URL to be `127.0.0.1`, i.e. localhost. 

If you're are running `docker` via `docker-machine` (like on Mac or Windows), then `docker` is actually running inside a VM and the server is attached to the VM's network interface, not localhost. You can forward the necessary port on localhost to the VM with the following commmand:

```
ssh docker@$(docker-machine ip) -L 80:localhost:80 -N
```

(when prompted, the password is `tcuser`; also, if you're doing this on Mac/Linux you probably need to run this with `sudo`). The forwarding will be active until you interrupt the above command.

If you are running the server somewhere remotely, you will have to set up the necessary extra port forwarding manually, or alternatively you can change the server URL from the default to the one at which the remote server is accessible.


At this point, your BOINC server is now 100% fully functioning, its webpage can be accessed at `http://127.0.0.1/boincserver`, and it is ready to accept connections from clients and submission of jobs. 


### Running jobs

Traditionally, creating a BOINC application meant either compiling your code into static binaries for each platform you wanted to support (e.g. 32 and 64-bit Linux, Windows, or Mac), or creating a Virtualbox image housing your app. Instructions for creating these types of applications can be found [here](https://boinc.berkeley.edu/trac/wiki/BasicApi) or [here](https://boinc.berkeley.edu/trac/wiki/VboxApps), and work just the same with `boinc-server-docker`. 

In this guide, however, we describe an easier way to run jobs which uses `boinc2docker`. This tool (which comes preinstalled with `boinc-server-docker`) lets you package your science applications inside Docker containers which are then delivered to your hosts. This makes your code automatically work on Linux, Windows, and Mac, and allows it to have arbitrary dependencies (e.g. Python, etc...) The trade-off is that it only works on 64-bit machines (most of BOINC anyway), requires users to have Virtualbox installed, and does not (currently) support GPUs. 

To begin, we give a brief introduction to running Docker containers in general. The syntax to run a Docker container is `docker run <image> <command>` where `<image>` is the name of the image and `<command>` is a normal Linux shell command to run inside the container. For example, the Docker Hub provides the image `python:alpine` which has Python installed (the "alpine" refers to the fact that the base OS for the Docker image is Alpine Linux, which is super small and makes the entire container be only ~25Mb). Thus you could execute a Python command in this container like, 

```bash
docker run python:alpine python -c "print('Hello BOINC')"
```
and it would print the string "Hello BOINC". 

Suppose you wanted to run this as a BOINC job. To do so, first get a shell inside your server with `docker exec -it boincserverdocker_apache_1 bash` and from the project directory run, 

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

The first step is to copy one of these two folders to a new folder, which for the purpose of this guide we will call `myproject/` (you can, and should, version control this folder so that you have your project's entire history saved, e.g. like [Cosmology@Home](https://github.com/marius311/cosmohome)). The folder structure will look like this, 

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

#### Building and running your server

The test server did not require us to build any Docker containers because these were pre-built, stored on the Docker Hub, and were downloaded to your machine when you executed the `docker-compose up -d` command. The images which comprise your server, on the other hand, need to be built; the command to do so is simply `docker-compose build`. 

Afterwards, you can run a `docker-compose up -d` just as before to start the server. Of course, at this point you have made no modifications at all so the server is identical to the test server. We will discuss how to customize your server shortly. Note that you can combine the build and run commands into one with `docker-compose up -d --build`.

To stop your server, run `docker-compose down`. If you wish to reset your server entirely (i.e. to also delete the volumes housing your database and project folder), run `docker-compose down -v`. 


#### Pinning the `boinc-server-docker` version

If you open up one of the Dockerfiles for one of the three images comprising your server, for example `myproject/images/apache/Dockerfile`, you will see this:

    FROM boinc/server_apache:latest-b2d

We have not discussed Dockerfile commands yet, but they are fairly simple, and you only need to know about three of them to use `boinc-server-docker`. One of them is the `FROM` command which always comes at the beginning of a Dockerfile and specifies that this image is built starting from another image. In our case it is saying that the Apache image for your server is based on the `boinc-server-docker` image called `boinc/server_apache:latest-b2d`. 

An important step you should take is to replace `latest` with a specific version, for example `1.2.1`, and you should do so for all three Dockerfiles. You can find the latest version of `boinc-server-docker` by looking at the [GitHub releases](https://github.com/marius311/boinc-server-docker/releases). With the versions pinned in this way, you can control exactly when you upgrade the version of `boinc-server-docker` that your server uses, and you can reproducibly go back to any previous version of your server. 


### Installing software

By default the `boinc-server-docker` images come with as few unnecessary programs as possible. For example, the Apache container, which you will often use to run various server commands, does not by default include a text editor. You *could* run `apt-get install vim` from inside the Apache container, but note that if you now stop and start the container, `vim` will be gone. This is because files inside Docker containers are not persisted unless they are in a volume. The correct way to install software like `vim` or anything else is to do so in the Dockerfile which builds that image. 

Again opening up `myproject/images/apache/Dockerfile`, we can change it to say

    FROM boinc/server_apache:latest-b2d

    RUN apt-get update && apt-get install -y vim
    
`RUN` is another Dockerfile command and simply runs a regular Linux shell command inside our container. We need an `apt-get update` to pull the latest package information and the `-y` flag automatically answers "yes" when `apt-get` asks whether you really want to install the package. If we now run `docker-compose up -d --build`, it will produce a new Apache image for our project and start it up, swapping out the old version (that lacked `vim`). If you now get a shell inside the container with `docker exec -it boincserverdocker_apache_1 bash` you will see that `vim` is correctly installed, and will still exist if you restart the container. 

In exactly this way you can install any software into any of the containers, or run any commands that might be necessary to set them up. These commands are for the general set up of the server; for things like submitting jobs, performing server maintenance tasks like database optimization, etc... you can just get a shell into the server and run the commands directly from there.

#### Custom `config.xml` and other files

Next you will probably want to give your project a name, give it a URL, and more generally copy things into the server and change various files. Lets take a look at changing the project name. This is specified in the file `/root/project/html/project/project.inc` inside the Apache Docker container. In this file there is a line, 

    define("PROJECT", "REPLACE WITH PROJECT NAME");

You can edit this file from inside the Apache container to replace the project name with whatever you'd like, and you can immediately see the change if you refresh the project webpage. 

     

#### Digitally signing your apps


### Typical steps

#### Custom server scripts and dependencies

#### Custom `boinc2docker`-based apps

#### 

### Advanced steps

#### Squashing images
