FROM debian:jessie

MAINTAINER Marius Millea <mariusmillea@gmail.com>

# install necessary packages
RUN apt-get update && apt-get install -y \
        curl \
        dh-autoreconf \
        git \
        libcurl4-gnutls-dev \
        libmysqlclient-dev \
        libssl-dev \
        m4 \
        make \
        php5-cli \
        php5-gd \
        php5-mysql \
        pkg-config \
        python \
        python-mysqldb


# get source and compile server
COPY boinc /root/boinc
RUN cd /root/boinc && ./_autosetup && ./configure --disable-client --disable-manager && make

# get boinc2docker
COPY boinc2docker /root/boinc2docker
RUN cd /root/boinc2docker \
    && ISOTAG=v0.44 VBOXTAG=v0.7 ./setup_versions

# build configuration
ENV USER=root PROJHOME=/project

# make project
RUN cd /root/boinc/tools \
    && ./make_project --url_base http://www.boincserver.com \
                      --project_host boincserver \
                      --db_host mysql \
                      --db_user root \
                      --no_db \
                      --no_query \
                      --project_root $PROJHOME \
                      boincserver \
    && mv $PROJHOME $PROJHOME.build && ln -s $PROJHOME.build $PROJHOME \
    && sed -i -e 's/Deny from all/Require all denied/g' \
           -e 's/Allow from all/Require all granted/g' \
           -e '/Order/d' $PROJHOME/boincserver.httpd.conf \
    && echo "admin:zJiQQ3OoIfehM" > $PROJHOME/html/ops/.htpasswd

# install boinc2docker
RUN cd /root/boinc2docker && ./install_as $PROJHOME boinc2docker 1.00

# project files
RUN mkdir $PROJHOME/html/stats_archive
COPY project.xml boinc2docker/plan_class_spec.xml db_dump_spec.xml $PROJHOME/

# finish up 
RUN unlink $PROJHOME
ONBUILD RUN ln -s $PROJHOME.build $PROJHOME
COPY postbuild.py /root/
