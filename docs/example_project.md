Customizing the Server
======================

To create your own project which uses these images but has its own customizations, simply create some Docker images which extend the builtin ones. The [/example_project](/example_project) folder contains an example of such a project. 

### makeproject image

You will generally want to modify the `makeproject` image to,

* Copy in any custom files (modified `config.xml`, modified web pages, etc...)
* Sign your executables with your own private keys

The Dockerfile below gives you an example of doing these two things, 

```Dockerfile
FROM marius311/boincserver_makeproject:latest

# copy in custom config.xml
COPY config.xml $PROJHOME/config.xml

# sign executables
COPY keys $PROJHOME/keys
RUN for f in `find $PROJHOME/apps/ -type f -not -name "version.xml"`; do \
      /root/boinc/tools/sign_executable $f $PROJHOME/keys/code_sign_private > ${f}.sig; \
    done \
    && rm $PROJHOME/keys/code_sign_private

# finish up
RUN unlink /root/projects
```

### apache image

You may need to modify the Apache image to install any packages needed by your scripts. Say you wrote a validator that requires Python Numpy, then you might write a Dockerfile for the Apache image that looks like, 

```Dockerfile
FROM marius311/boincserver_apache:latest

# needed by validator
RUN apt-get update && apt-get install -y python-numpy
```


### docker-compose.yml

Finally, you'll need to make a copy of docker-compose.yml and and modify it as necessary to use the your custom images, so e.g. you might replace the lines,

```yml
    image: marius311/boincserver_makeproject:latest
    build: images/makeproject
```

with

```yml
  makeproject:
    image: myproject_makeproject:latest
    build: images/makeproject
```

assuming you've put the `makeproject` Dockerfile in the `images/makeproject` folder. If you don't need to modify other images, e.g. the mysql image, you can just leave those part as is.

### Workflow

The idea is that when you modify some project files, you then rerun `make makeproject post-makeproject` which rebuilds the `boincserver_makeproject` image and reruns the `postbuild.py` script, overwriting existing files in your project directory while leaving existing ones (like upload and download files) there. 
