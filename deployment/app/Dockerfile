# vim:set ft=dockerfile:
FROM node:10-alpine AS build

ARG CADDY_PLUGINS=http.cors,http.minify

ENV RAILS_ENV=production \
    APP_ENV=production \
    RACK_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    NODE_ENV=production \
    BUNDLE_PATH=/vendor \
    GEM_HOME=/vendor \
    BUNDLE_BIN=/vendor/bin \
    PATH=$PATH:/vendor/bin \
    APP_ROOT=/app \
    RAILS_LOG_BASE_PATH=/app/log/ \
    RAILS_PUBLIC_UPLOADS_PATH=/uploads \
    CADDYPATH=/var/lib/caddy

WORKDIR /app

RUN apk add --no-cache --update build-base \
                                git \
                                python \
                                py2-pip \
                                ruby \
                                ruby-dev \
                                ruby-bigdecimal \
                                ruby-webrick \
                                ruby-etc \
                                postgresql-dev \
                                nodejs \
                                tzdata \
                                git \
                                icu-dev \
                                curl \
                                ca-certificates && \
    gem install --no-document compass && \
    mkdir -p config && \
    ARCH=$(apk --print-arch | sed 's/x86_64/amd64/') && \
    curl -sfSL "https://caddyserver.com/download/linux/$ARCH?plugins=$CADDY_PLUGINS&license=personal&telemetry=off" | tar -xz -C /tmp && \
    mv /tmp/caddy /usr/bin/caddy

COPY package.json ./package.json
COPY package-lock.json ./package-lock.json
COPY vendor/assets ./vendor/assets

RUN npm config set loglevel info && \
    NODE_ENV=development npm install --verbose

COPY bower.json ./bower.json
COPY carto-package.json ./carto-package.json
COPY Gruntfile.js ./Gruntfile.js
COPY config/osm2pgsql.style ./config/osm2pgsql.style
COPY config/editor_assets_version.json ./config/editor_assets_version.json
COPY config/grunt_development.json ./config/grunt_development.json
COPY deployment/app/grunt_production.json ./config/grunt_production.json
COPY config/custom_basemaps ./config/custom_basemaps

# Needed by lib/tasks/random_data.rake
COPY spec/support/factories/tables.rb ./spec/support/factories/tables.rb
COPY spec/helpers/unique_names_helper.rb ./spec/helpers/unique_names_helper.rb

COPY app/ ./app/
COPY config ./config/
COPY db ./db/
COPY lib ./lib/
COPY gears ./gears/
COPY services ./services/
COPY script ./script/
COPY assets ./assets
COPY webpack ./webpack
COPY public ./public/

RUN npm run carto-node && \
    npm run build:static

COPY .git ./.git

RUN ./node_modules/grunt-cli/bin/grunt --environment=production

COPY Gemfile Gemfile.lock config.ru package.json Rakefile ./

RUN apk add --no-cache zlib-dev linux-headers

COPY deployment/app/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    gem install --no-ri --no-rdoc bundler -v 1.17.3 && \
    gem install --no-ri --no-rdoc bigdecimal && \
    bundle --deployment --path /vendor/ --without development test

COPY /deployment/app/Caddyfile /etc/caddy/

VOLUME /uploads

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["unicorn", "-d", "-p", "80"]
