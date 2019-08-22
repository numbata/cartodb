# vim:set ft=dockerfile:
FROM alpine:edge

ENV CDB_VALID_VERSION=0.30.0 \
    PGDATA=/var/lib/postgresql/data \
    LANG=en_US.utf8

WORKDIR /tmp

RUN set -ex && \
    apk add --repository http://nl.alpinelinux.org/alpine/edge/testing --no-cache --update  --virtual .fetch-deps \
            build-base \
            ca-certificates \
            wget \
            bash \
            ruby \
            python2-dev \
            git && \
    apk add --repository http://nl.alpinelinux.org/alpine/edge/testing --no-cache --update  --virtual .pgdeps \
            postgresql-dev \
            postgresql-contrib \
            postgis \
            py3-hiredis \
            su-exec \
            postgresql-plpython2-contrib && \
    \
    export PG_CONF_DIR=$(pg_config --sysconfdir) && \
    mkdir -p "$PG_CONF_DIR" && \
    mkdir -p "$PGDATA" && \
    chown -R postgres:postgres "$PGDATA" && \
    chmod 777 "$PGDATA" && \
    \
    git clone -b $CDB_VALID_VERSION https://github.com/CartoDB/cartodb-postgresql.git && \
    cd cartodb-postgresql && \
    make all install && \
    \
    cd /tmp && \
    wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py && \
    python get-pip.py && \
    pip install hiredis && \
    \
    git clone https://github.com/CartoDB/dataservices-api.git && \
    cd /tmp/dataservices-api/client && \
    make install && \
    cd /tmp/dataservices-api/server/extension && \
    make install && \
    cd /tmp/dataservices-api/server/lib/python/cartodb_services && \
    pip install -r requirements.txt && \
    pip install . --upgrade && \
    \
    apk del .fetch-deps && \
    ln -sf /dev/stdout /var/log/postgresql/postgresql.log

COPY deployment/postgresql/docker-entrypoint.sh /usr/local/bin/
COPY deployment/postgresql/pg_hba.conf /tmp/pg_hba.conf
RUN  chmod +x /usr/local/bin/docker-entrypoint.sh && \
     cp /tmp/pg_hba.conf $(pg_config --sysconfdir)/pg_hba.conf

VOLUME /var/lib/postgresql/data
EXPOSE 5432

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
