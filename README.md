
boinc-server-docker
===================

First get the BOINC server up:
```bash
git clone https://github.com/marius311/boinc-server-docker.git
cd boinc-server-docker
make pull #this downloads the Docker images, you'll only need to do it the first time
make up
```

Then add the line `127.0.0.1 www.boincserver.com` to your `/etc/hosts` file. After this, you can visit the server webpage and/or connect a BOINC client at the URL [www.boincserver.com/boincserver](http://www.boincserver.com/boincserver). 

Now to create some jobs. First run `make exec-apache` to get a shell inside the server. Now run the `bin/boinc2docker_create_work.py` command, which is meant to look like like a `docker run`, so e.g. 
```
bin/boinc2docker_create_work.py debian:latest sh -c "echo Hello World! > /root/shared/results/myresult"
```

This creates the job, and any connected clients will now download and run this job. Any files written to `/root/shared/results` from the container are tar'ed up and sent back to the server.
