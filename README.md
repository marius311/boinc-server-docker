
boinc-server-docker
===================

`boinc-server-docker` is the easiest way to run your own [BOINC](http://boinc.berkeley.edu/) server. The only requirements on your host system are,

* [Docker](https://github.com/docker/docker/releases) 1.10+
* [docker-compose](https://github.com/docker/compose/releases) 1.6.0+
* make
* git 

To check out the repository and get a test server fully up and running, simply run,
```bash
git clone https://github.com/marius311/boinc-server-docker.git
cd boinc-server-docker
make pull
make up
```

The server URL is hardcoded as www.boincserver.com, so to test the server on your machine you will need to reroute this to localhost, which can be achieved by adding the line `127.0.0.1 www.boincserver.com` to your `/etc/hosts` file. At this point you can connect a web browser or BOINC client to www.boincserver.com/boincserver to see the server web page or run jobs. 


Running jobs
------------

`boinc-server-docker` also comes with [`boinc2docker`](https://github.com/marius311/boinc2docker) installed, which means you can immediately submit Docker jobs to the server which will be run by any connected clients. To submit jobs, first run `make exec-apache` to get a shell inside the server. 

Now run the `bin/boinc2docker_create_work.py` command, which is meant to look like like a `docker run`, so e.g. 
```
bin/boinc2docker_create_work.py debian:latest sh -c "echo Hello World! > /root/shared/results/myresult"
```

This creates the job, and any connected clients will now download and run this job. Note that any files written to `/root/shared/results` from the container are tar'ed up and sent back to the server. `bin/boinc2docker_create_work.py` has a few Docker-like options, like `--entrypoint`, and many BOINC-like options, like `--target_nresults`, etc... See `bin/boinc2docker_create_work.py -h` for a list of all options. 


Creating your real server
-------------------------

This package is not just a way to get a simple empty test server up and running, its also the best way to actually run your real server (for example, this is how the [Cosmology@Home](www.cosmologyathome.org) server runs). By running your server in production with `boinc-server-docker`, you can transparently go from development to deployment with the assurance your code will work exactly the same, you can version control your entire server, and you can easily stay up to date with the latest BOINC/Apache/mysql releases.

For instructions on how to do this, see [example_project.md](/docs/example_project.md).

Contributing
------------

See [overview.md](/docs/overview.md) and [TODO.md](/docs/TODO.md) and please contact [me](https://github.com/marius311)!
