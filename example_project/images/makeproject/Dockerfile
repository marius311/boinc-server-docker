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
