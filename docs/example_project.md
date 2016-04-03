Creating your real server
=========================

## Intro

This page explains how to customize your server, for example adding apps or changing the appearance of the web pages. You will need some familiarity with BOINC and with Docker. 

First, start by making a copy of [/example_project](/example_project) to a new folder which will store your server (you can, and should, version control this folder). The server is made up of three Docker containers, 

* `makeproject` - this builds your project folder
* `apache` - this runs the Apache web server, scheduler, and various daemons that make up the server
* `mysql` - this runs the mysql server holding your project database

Each is built from a `Dockerfile` in the `example_project/images/` subfolders. To general idea to customize your server is that you change the `Dockerfile`'s to build the images according to your own customziations (see below for some examples). 

After making modifications, you run `make build` from your copy of the `example_project` folder to build your customized images, and `make up` to start the server (if your server is already running, this will simply swap in any images which have changed).

If you are not familiar with Docker, don't despair, writing Dockerfiles is pretty easy and intuitive. Here is a [reference](https://docs.docker.com/engine/reference/builder/) for how to write Dockerfiles (you will probably only really need two commands, `RUN` and `COPY`). Also, as an [example](https://github.com/marius311/cosmohome/blob/master/Dockerfile), this is the `Dockerfile` which builds Cosmology@Home.

## Examples

Here are some examples of how you might customize the different images.

### apache image

The `apache` image runs the web server and the various BOINC daemons (scheduler, validators, etc...). Software needed by your daemons should be installed in this image.

The default `Dockerfile` looks like this:
```Dockerfile
FROM boinc/server_apache:latest
```

Suppose that your validator needs the Python Numpy package, then you would install Numpy into this image by changing `Dockerfile` to,

```Dockerfile
FROM boinc/server_apache:latest
RUN apt-get update && apt-get install -y python-numpy
```

### makeproject image

The `makeproject` images creates your project folder. You will generally want to modify the `makeproject` image to,

* Copy in any custom files (modified `config.xml`, modified web pages, etc...)
* Copy in any new applications
* Sign your executables with your own private keys

The default `Dockerfile` looks like this:

```Dockerfile
FROM boinc/server_makeproject:latest
```

Say you want to add your own `config.xml`. You would place the file in your `images/makeproject` folder, then modify the `Dockerfile` so that it contains,

```Dockerfile
FROM boinc/server_makeproject:latest
COPY config.xml $PROJHOME/config.xml
```

You can copy in any other project files like your apps, web pages, etc... in this manner. You will also need to sign executables here. To do so, place your code signing keys in the `images/makeproject/keys` folder, then modify you Dockerfile so that it contains,

```Dockerfile
FROM boinc/server_makeproject:latest
COPY keys $PROJHOME/keys
RUN bin/sign_all_apps
```

**Warning:** Currrently this leaves your private keys in the image history, so do not push this image to any public registry like the Docker hub. A future version will fix this. 

Note also that there are two available base `makeproject` images that you can start from,

* `boinc/server_makeproject:latest` comes with no applications pre-installed 
* `boinc/server_makeproject:latest-b2d` comes with `boinc2docker` pre-installed


### mysql image

TODO: write this
