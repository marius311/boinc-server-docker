## Immediate tasks (in order of importance). 
Note: some of these involve contributions to BOINC, not this project directly:

#### 1. Create a Dockerized client / unit tests

When you make some updates to the code, you either have to test by hand nothing broke, or just launch in production hoping that nothing did. Of course, it'd be better if we had unit tests. These tests should involve actually connecting a BOINC client to server, hence we should probably Dockerize a client. This will involve getting Virtualbox working inside Docker (since our jobs need a client with Virtualbox), and possibly also the client GUI (although technically you can have the GUI on your machine and connect it to the Dockerized client).

#### 2. Add persistence drive ability to vboxwrapper

Right now the Docker image for a `boinc2docker` job is loaded from BOINC input files at the beginning of each job. This can be slow and because the VM uses a RAM disk we have to store the entire image in memory. If we had a persistence disk we could only take the delay of load the image once and also not have to store it in RAM. This task would require adding the concept a persistence disk to `vboxwrapper`. 

#### 3. Fix BOINC detection of VT-x/AMD-v

Our VM's are 64-bit so they need VT-x/AMD-v. Right now if a user doesn't know about VT-x/AMD-v and have it disabled and they try to run our job, they'll get a job, after 5min of inactivity it will fail, and the message telling them about VT-x/AMD-v will be buried in a log which they need to go to the website to read. After they enable it, they will probably be bit by this bug (https://github.com/BOINC/boinc/issues/1460). Overall its a pretty unpleasant experience, which should be improved. This would take changes to the BOINC client so it'll be hard for those unfamiliar with that code base. It is high on the priority list though. 

#### 4. Fix vboxwrapper Guest logging

vboxwrapper logs the output from the "vboxmonitor" program but the way its coded it seems to often miss lines of log. At the very least it was written to only scan the last 8k of the log a time, so a sudden long log output will definitely cause it to miss things. To me it seems like it misses things in other cases as well though. To be investigated. 


#### 7. Add an SMTP server to boinc-server-docker 

BOINC needs an SMTP server, it'd be nice if this were part of boinc-server-docker (https://github.com/marius311/boinc/blob/cosmohome/html/project.sample/project.inc#L37). 



## Cool general ideas (no order):

#### MPI
    
The majority of scienitifc codes (that I know) are parallelized with MPI. So we log onto an HPC cluster which has a bunch of nodes all seeing a same shared filesystem, and `mpiexec -n 200 myprogram` to run 200 processes, which communnicate with each other via MPI. Allowing one to run MPI over a BOINC project would attract a lot of interest from scientists. The end goal would be something like: I'm sitting on my BOINC server and I run `boinc_mpiexec -n 200 myimage` and this starts the 200 jobs on the volunteers computers, the jobs themselves being a Docker image `myimage` and allows them to intercommunicate with each other with MPI. Challenges here include that you can't assume volunteers computers will start the job as soon as you tell them, it could take literally days, jobs can die without notice, and the intercommunication would require some level of NAT traversal. 

#### Swarm

Another similar idea is to run a Docker Swarm on the volunteers. So now I'm sitting on my BOINC server and I can issue a `docker run ...` which just gets sent to the Swarm. My understanding is that Swarm can do multihost networking and that it has some sort of automatic node discovery, so perhaps the NAT traversal issue is solved already here? This is perhaps a more general thing than MPI (once I have a Swarm I have a "virtual cluster" and I can run whatever I want on it transparently, including MPI), and the MPI thing could even be built ontop of this. 


#### MCMC chains

One type of analysis that is ubiquitus in cosmology is running a "Markov Chain Monte Carlo" (MCMC) analyis. Basically this is a way to draw samples from a likelihood function, we use it to figure out constraints on parameters given data. We as a field are definitely going to be doing this for the next 10+ years. So of course, it would be cool and useful to be able to run MCMC chains on a BOINC project. Again this generally requires intercommunication between volunteers and fault tolerance, but its a much more specific task than Swarm/MPI, so maybe that simplifies things. This is interesting also from the standpoint of maybe selecting a particular MCMC algorithm that is well suited to the constraints of a BOINC project. Metropolis-Hastings is popular, but perhaps something like Goodman-Weare (which has a nice Python package "emcee") works better?

#### Secret data

This is my least well thought out idea but might be intersting and fun to think about purely from a computer theory perspective. If I have some secret data (i.e. data from my experiment or something which is not public yet), I can't analyze it on BOINC because any users can always look at the whole contents of the image I'm sending them. But is there some clever way in which I can still run a useful analysis without the users being able to see my data exactly? 
