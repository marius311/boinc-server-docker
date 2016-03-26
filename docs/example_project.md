Creating your real server
=========================

## Intro

As described in [README.md](../README.md), running `make up` from the root of this repository will start an empty test BOINC server. This page explains how to customize your server, for example adding apps or changing the appearance of the web pages. You will need some familiarity with BOINC and with Docker. 

First, start by making a copy of [/example_project](/example_project) to a new folder which will store your server (you can, and should, version control this folder). The server is made up of three Docker containers, 

* `makeproject` - this builds your project folder
* `apache` - this runs the Apache web server, scheduler, and various daemons that make up the server
* `mysql` - this runs the mysql server holding your project database

Each is built from a `Dockerfile` in the `example_project/images/` subfolders. To customize your server, simply change these files so the images are built according to your own customziations. Then run `make build` to build the images, and then `make up` to start the server containers (if a container is already running, you remove it with `make rm-X` where `X` is either `apache` or `mysql`). 

## Examples

Here are some examples of how you might customize the different images.

### apache image

The `apache` image holds the web server, scheduler, and various daemons. Software needed by your daemons should be installed here (things like custom project web pages should instead be installed in the `makeproject` image). 

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

Note there are two base `makeproject` images that you can start from,

* `boinc/server_makeproject:latest` comes with no applications pre-installed 
* `boinc/server_makeproject:latest-b2d` comes with `boinc2docker` pre-installed

Suppose you wanted to use `boinc2docker`, copy in a custom `config.xml` file, and sign the exeuctables using your own private keys. First place your custom `config.xml` file and a folder `keys/` containing your private keys in your `/images/makeproject` folder. Then modify the `Dockerfile` to,

```Dockerfile
FROM boinc/server_makeproject:latest-b2d

# copy in custom config.xml
COPY config.xml $PROJHOME/config.xml

# sign executables
COPY keys $PROJHOME/keys
RUN for f in `find $PROJHOME/apps/ -type f -not -name "version.xml"`; do \
      /root/boinc/tools/sign_executable $f $PROJHOME/keys/code_sign_private > ${f}.sig; \
    done \
    && rm $PROJHOME/keys/code_sign_private

# finish up
RUN unlink $PROJHOME
```


### mysql image

TODO: write this
