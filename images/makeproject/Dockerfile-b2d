FROM debian:jessie-slim

LABEL maintainer="Marius Millea <mariusmillea@gmail.com>"

# install necessary packages
RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dh-autoreconf \
        g++ \ 
        git \
        libcurl4-gnutls-dev \
        libmysqlclient-dev \
        m4 \
        make \
        mysql-client \
        php5-cli \
        php5-mysql \
        pkg-config \
        python \
        python-mysqldb \
        python-yaml \
        wget \
    && apt-get install -y -t jessie-backports libssl-dev \
    && rm -rf /var/lib/apt/lists

# get source and compile server
COPY boinc /root/boinc
RUN cd /root/boinc && ./_autosetup && ./configure --disable-client --disable-manager && make

# these can't be changed (yet). for variables which *can* be changed, see the .env file
ENV USER=root PROJECT_ROOT=/root/project

# make project
RUN cd /root/boinc/tools \
    && ./make_project --url_base 'http://${url_host}' \
                      --project_host '${project}' \
                      --db_host mysql \
                      --db_user root \
                      --no_db \
                      --no_query \
                      --project_root $PROJECT_ROOT \
                      '${project}' \
    && sed -i -e 's|http://${url_host}|\${url_base}|g' $PROJECT_ROOT/config.xml $PROJECT_ROOT/html/user/schedulers.txt \
    && sed -i -e 's/Deny from all/Require all denied/g' \
              -e 's/Allow from all/Require all granted/g' \
              -e '/Order/d' $PROJECT_ROOT/*.httpd.conf \
    && echo "admin:zJiQQ3OoIfehM" > $PROJECT_ROOT/html/ops/.htpasswd \
    && chmod g+w $PROJECT_ROOT/download \
    && rm -r $PROJECT_ROOT/log_*

# create boinc2docker app
COPY boinc2docker /root/boinc2docker
ENV PATH=/root/boinc2docker:$PATH
# the vboxwrapper/iso/appver installed will be taken from boinc2docker/boinc2docker.yml
RUN boinc2docker_create_app --projhome $PROJECT_ROOT

# project files
RUN mkdir $PROJECT_ROOT/html/stats_archive
COPY db_dump_spec.xml $PROJECT_ROOT/
COPY html $PROJECT_ROOT/html
COPY bin $PROJECT_ROOT/bin

# finish up 
WORKDIR $PROJECT_ROOT
COPY makeproject.sh /root/
CMD /root/makeproject.sh
