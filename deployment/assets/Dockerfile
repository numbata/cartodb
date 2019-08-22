# vim:set ft=dockerfile:
FROM node:10-alpine AS build

WORKDIR /app

ENV NODE_ENV=production \
    APP_ENV=production \
    RAILS_ENV=production \
    RACK_ENV=production

RUN apk add --no-cache --update build-base \
                                git \
                                py2-pip && \
    apk add --no-cache ruby ruby-dev && \
    gem install --no-document compass && \
    apk del --no-cache ruby-dev && \
    mkdir -p config

COPY package.json ./package.json
COPY package-lock.json ./package-lock.json

RUN NODE_ENV= npm install

COPY bower.json ./bower.json
COPY carto-package.json ./carto-package.json
COPY Gruntfile.js ./Gruntfile.js
COPY config/osm2pgsql.style ./config/osm2pgsql.style
COPY config/editor_assets_version.json ./config/editor_assets_version.json
COPY config/grunt_development.json ./config/grunt_development.json
COPY deployment/assets/grunt_production.json ./config/grunt_production.json
COPY config/custom_basemaps ./config/custom_basemaps

COPY vendor/assets ./vendor/assets
COPY lib/assets ./lib/assets
COPY lib/build ./lib/build
COPY app/assets ./app/assets
COPY assets ./assets
COPY webpack ./webpack
COPY public ./public/

RUN npm run carto-node && \
    npm run build:static

COPY .git ./.git

RUN ./node_modules/grunt-cli/bin/grunt --environment=production

# FROM nginx:stable-alpine
#
# COPY --from=build /app/public/ /var/www
# COPY deployment/assets/nginx.conf /etc/nginx/conf.d/default.conf
#
# RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
#     ln -sf /dev/stderr /var/log/nginx/error.log
#
# STOPSIGNAL SIGTERM
#
# CMD ["nginx", "-g", "daemon off;"]

FROM alpine:3.4

ARG CADDY_PLUGINS=http.cors,http.minify
ENV CADDYPATH /var/lib/caddy

RUN ARCH=$(apk --print-arch | sed 's/x86_64/amd64/') && \
  apk --no-cache add curl ca-certificates git && \
  curl -sfSL "https://caddyserver.com/download/linux/$ARCH?plugins=$CADDY_PLUGINS&license=personal&telemetry=off" \
    | tar -xz -C /tmp && \
  mv /tmp/caddy /usr/bin/caddy

COPY --from=build /app/public/ /var/www
COPY /deployment/web/Caddyfile /etc/caddy/

EXPOSE 80 443
CMD ["caddy", "-conf", "/etc/caddy/Caddyfile"]
