FROM debian:jessie

MAINTAINER Marius Millea <mariusmillea@gmail.com>

#install necessary packages
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


#get source and compile server
COPY boinc /root/boinc
WORKDIR /root/boinc
RUN ./_autosetup && ./configure --disable-client --disable-manager && make

#make project
RUN mkdir -p /root/projects.build && ln -s /root/projects.build /root/projects
ENV USER=root
ENV PROJHOME=/root/projects/boincserver
WORKDIR /root/boinc/tools
RUN ./make_project --url_base http://www.boincserver.com \
                   --project_host boincserver \
                   --db_host mysql \
                   --db_user root \
                   --no_db \
                   --no_query \
                   boincserver
RUN sed -i -e 's/Deny from all/Require all denied/g' \
           -e 's/Allow from all/Require all granted/g' \
           -e '/Order/d' $PROJHOME/boincserver.httpd.conf
RUN echo "admin:zJiQQ3OoIfehM" > $PROJHOME/html/ops/.htpasswd

# install boinc2docker
COPY boinc2docker $PROJHOME/boinc2docker
RUN cd $PROJHOME/boinc2docker \
    && ISOTAG=v0.43 VBOXTAG=v0.6 ./setup_versions \
    && ./install_as $PROJHOME boinc2docker 1.00

# project files
RUN mkdir $PROJHOME/html/stats_archive
COPY project.xml boinc2docker/plan_class_spec.xml db_dump_spec.xml $PROJHOME/

# finish up 
COPY postbuild.py /root/
