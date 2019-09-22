# vim:set ft=dockerfile:
FROM node:10-alpine AS build

ARG APP_ENV=production
ARG MAPS_API_VERSION=7.1.0

ENV NODE_ENV=$APP_ENV \
    PATH=$PATH:/vendor/bin \
    APP_ROOT=/app

RUN apk add --no-cache --update python \
                                py2-pip \
                                libpq \
                                nodejs \
                                tzdata \
                                freetype \
                                icu-libs \
                                libjpeg \
                                libpng \
                                libc6-compat \
                                pango \
                                curl \
                                giflib-dev \
                                cairo \
                                boost \
                                boost-program_options \
                                ca-certificates

RUN apk add --no-cache --update --virtual .buildeps \
                                build-base \
                                git \
                                bash \
                                g++ \
                                boost-dev \
                                freetype-dev \
                                icu-dev \
                                libjpeg-turbo-dev \
                                libpng-dev \
                                zlib-dev \
                                libxml2-dev \
                                harfbuzz-dev \
                                cairo-dev \
                                pango-dev \
                                postgresql-dev

RUN git clone -b $MAPS_API_VERSION -- https://github.com/CartoDB/Windshaft-cartodb.git /app && \
    cd /app && \
    npm config set loglevel info && \
    npm install --verbose

RUN apk del .buildeps

WORKDIR /app

COPY deployment/sql_api/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh", "-c", "node app.js $APP_ENV"]
