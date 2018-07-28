# Server development workflow with `boinc-server-docker`

Here is how quickly set up a BOINC server development environment. First, clone this repository, build the images locally, and start the server:


```bash
git clone --recursive https://github.com/marius311/boinc-server-docker.git
cd boinc-server-docker
docker-compose build
docker-compose up -d
```

Now enter the folder `images/makeproject/boinc` in the root of this repository, which is a Git submodule pointing to the BOINC repository. You can make whatever changes to files you need, checkout any specific commits you want, or in general do whatever development you need. 

Now to recompile the BOINC source with your changes and update the running server, do:

```bash
docker-compose -f docker-compose.yml -f docker-compose-dev.yml run --rm makeproject
```

This will recompile the BOINC code directly in `images/makeproject/boinc`, but will do so in a Docker container so that no dependencies are necessary on your local machine.

This above command is equivalent to running the `_autosetup`, `configure`, and `make` commands necessary to compile the server. After the first time, it will be faster to only run `make`, in which case only newly modified files will lead to recompilation:

```bash
docker-compose -f docker-compose.yml -f docker-compose-dev.yml run --rm makeproject make
```

No extra commands are necessary, as the updated files are automatically updated into your running server containers.


The location of the local BOINC source which is compiled is controlled by the `BOINC_SRC_DIR` variable, which by default points to `images/makeproject/boinc`. You can change this to point to arbitrary folders on your machine, e.g.:

```bash
BOINC_SRC_DIR=/path/to/boinc docker-compose -f docker-compose.yml -f docker-compose-dev.yml run --rm makeproject make
```
