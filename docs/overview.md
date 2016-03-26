Design Overview
---------------

`boinc-server-docker` is a [BOINC](https://github.com/BOINC/boinc) server running on a standard Linux-Apache-MySql-PHP stack which has been entirely containerized with Docker. 



Three separate images do the job:

* `boincserver_mysql` - An official Docker mysql image which runs the database storing users, hosts, jobs, etc...
* `boincserver_makeproject` - A debian container (built from [/images/makeproject/Dockerfile](/images/makeproject/Dockerfile)) which serves to build the project directory and initialize the database
* `boincserver_apache` - A slightly modified official Docker Apache-PHP image (built from [/images/apache/Dockerfile](/images/apache/Dockerfile)) which takes the project directory which was previously built and actually runs the server. 

These can be pulled from the Docker hub with `make pull`, or if you are doing development these can be built with `make build` (in which case make sure you've cloned this repository with `--recursive`, i.e. you have the submodules).

Three named volumes store server files, 

* `boincserver_mysql` - Stores the database
* `boincserver_project` - Stores the project directory
* `boincserver_results` - Stores results returned from users

Creation and management of the containers is done with docker-compose and the configuration file at [/docker-compose.yml](/docker-compose.yml). There is also a [Makefile](/Makefile) which is just shorthand for some of the docker-compose commands. To run the server, once you've built or pulled the images, 

* `make up-mysql` - Start the mysql container
* `make post-makeproject` - When the `boincserver_makeproject` image is built, it compiles the BOINC source code, runs BOINC's `./make_project` script to create the BOINC project folder structure, and copies in our various application files. There are three things we need to do to fully build the server which we can't do in this step because Docker doesn't allow linking containers or mounting volumes during the build step. These are performed by `make post-makeproject` which runs small script [postbuild.py](/images/makeproject/postbuild.py) which,
    * Copies files into the `boincserver_project` volume
    * Crates the database (if it doesn't exist)
    * Updates the database with any new applications we added (i.e. BOINC's `bin/update_versions` script) 
* `make up-apache` - Start the Apache server 

The command `make up` is equivalent to `make up-mysql post-makeproject up-apache`. 

The `make exec-apache` command gets you a shell inside the Apache container to perform maintenance or submit new jobs. 

