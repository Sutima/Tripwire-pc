FROM percona:5.7

USER root
RUN yum update -y && \
    yum install -y wget bzip2 && \
    yum clean all

COPY ./.docker/mysql/my.cnf /etc/my.cnf

COPY --chown=mysql:mysql ./.docker/mysql/docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=mysql:mysql ./.docker/mysql/init.sh /tmp/init.sh

RUN mkdir -p /docker-entrypoint-initdb.d/ && \
    touch /docker-entrypoint-initdb.d/init.sql && \
    chmod 777 /docker-entrypoint-initdb.d && \
    chmod 777 /docker-entrypoint-initdb.d/init.sql && \
    chmod +x /docker-entrypoint.sh && \
    chmod +x /tmp/init.sh

USER mysql

