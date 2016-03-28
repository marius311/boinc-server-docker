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

Suppose you wanted to copy in a custom `config.xml` file and sign the exeuctables using your own private keys. First place your custom `config.xml` file and a folder `keys/` containing your private keys in your `/images/makeproject` folder. Then modify the `Dockerfile` so that it contains,

```Dockerfile
FROM boinc/server_makeproject:latest

# copy in custom config.xml
COPY config.xml $PROJHOME/config.xml

# sign executables
COPY keys $PROJHOME/keys
RUN for f in `find $PROJHOME/apps/ -type f -not -name "version.xml"`; do \
      /root/boinc/tools/sign_executable $f $PROJHOME/keys/code_sign_private > ${f}.sig; \
    done \
    && rm $PROJHOME/keys/code_sign_private

```

**Warning:** Currrently this leaves your private keys in the image history, so do not push this image to any public registry like the Docker hub. A future version will fix this. 

Note also that there are two available base `makeproject` images that you can start from,

* `boinc/server_makeproject:latest` comes with no applications pre-installed 
* `boinc/server_makeproject:latest-b2d` comes with `boinc2docker` pre-installed


### mysql image

TODO: write this
