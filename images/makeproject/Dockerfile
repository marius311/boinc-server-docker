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
        php5-mysql \
        pkg-config \
        python \
        python-mysqldb


# get source and compile server
COPY boinc /root/boinc
RUN cd /root/boinc && ./_autosetup && ./configure --disable-client --disable-manager && make

# build configuration
ENV USER=root PROJHOME=/root/project

# make project
RUN cd /root/boinc/tools \
    && ./make_project --url_base http://127.0.0.1 \
                      --project_host boincserver \
                      --db_host mysql \
                      --db_user root \
                      --no_db \
                      --no_query \
                      --project_root $PROJHOME \
                      boincserver \
    && sed -i -e 's/Deny from all/Require all denied/g' \
           -e 's/Allow from all/Require all granted/g' \
           -e '/Order/d' $PROJHOME/boincserver.httpd.conf \
    && echo "admin:zJiQQ3OoIfehM" > $PROJHOME/html/ops/.htpasswd \
    && chmod g+w $PROJHOME/download \
    && rm -r $PROJHOME/log_boincserver

# project files
RUN mkdir $PROJHOME/html/stats_archive
COPY db_dump_spec.xml $PROJHOME/
COPY html $PROJHOME/html
COPY bin $PROJHOME/bin

# finish up 
WORKDIR $PROJHOME
COPY postbuild.py /root/
CMD /root/postbuild.py
