#!/usr/bin/env sh

set -ex

echo "Setup config/app_config.yml"
ruby <<-EOF
  require 'yaml'
  require 'pathname'
  require 'securerandom'

  APP_ROOT = Pathname.new(ENV.fetch('APP_ROOT', '/app'))
  CARTODB_DOMAIN = ENV.fetch('CARTODB_DOMAIN', 'cartodb')

  configs = YAML.load_file(APP_ROOT.join('config/app_config.yml.sample'))
  config  = configs['production']
  config['http_port'] = ENV.fetch('CARTODB_HTTP_PORT', 3000)
  config['https_port'] = ENV.fetch('CARTODB_HTTPS_PORT', 443)
  config['secret_token'] = ENV.fetch('CARTODB_SECRET_TOKEN', SecureRandom.hex(32))
  config['secret_key_base'] = ENV.fetch('CARTODB_SECRET_KEY_BASE', SecureRandom.hex(64))
  config['password_secret'] = ENV.fetch('CARTODB_PASSWORD_SECRET', SecureRandom.hex(64))
  config['account_host'] = ENV.fetch('CARTODB_ACCOUNT_HOST', CARTODB_DOMAIN)
  config['vizjson_cache_domains'] = Array(ENV.fetch('CARTODB_SESSION_DOMAIN', CARTODB_DOMAIN))
  config['subdomainless_urls'] = ['yes', 'true', '1'].include?(ENV.fetch('CARTODB_SUBDOMAINLESS_URLS', 'false'))
  config['aggregation_tables'] = {
    'host' => ENV.fetch('POSTGRES_HOST', 'db'),
    'port' => ENV.fetch('POSTGRES_PORT', '5432'),
    'dbname' => ENV.fetch('POSTGRES_DB', 'cartodb'),
    'username' => ENV.fetch('POSTGRES_USER', 'cartodb'),
    'password' => ENV.fetch('POSTGRES_PASSWORD', 'cartodb'),
    'tables' => {
      'admin0' => 'ne_admin0_v3',
      'admin1' => 'global_province_polygons'
    }
  }
  config['error_track']['url'] = "#{CARTODB_DOMAIN}/api/v1/sql"
  config['layer_opts']['data']['options']['tiler_domain'] = ENV.fetch('CARTODB_TILER_DOMAIN', CARTODB_DOMAIN)
  config['layer_opts']['data']['options']['sql_domain'] = ENV.fetch('CARTODB_SQL_DOMAIN', CARTODB_DOMAIN)
  config['cartodb_central_domain_name'] = ENV.fetch('CARTODB_CENTRAL_DOMAN', CARTODB_DOMAIN)
  config['redis']['host'] = ENV.fetch('REDIS_HOST', 'redis')
  config['tiler']['public']['domain'] = ENV.fetch('CARTODB_TILER_DOMAIN', CARTODB_DOMAIN)
  config['tiler']['internal']['domain'] = ENV.fetch('CARTODB_TILER_INTERNAL_DOMAIN', CARTODB_DOMAIN)
  config['tiler']['private']['domain'] = ENV.fetch('CARTODB_TILER_PRIVATE_DOMAIN', CARTODB_DOMAIN)
  config['sql_api']['public']['domain'] = ENV.fetch('CARTODB_SQL_DOMAIN', CARTODB_DOMAIN)
  config['sql_api']['private']['domain'] = ENV.fetch('CARTODB_SQL_PRIVATE_DOMAIN', CARTODB_DOMAIN)
  config['session_domain'] = ENV.fetch('CARTODB_SESSION_DOMAIN', CARTODB_DOMAIN)
  config['app_assets']['asset_host'] = ENV.fetch('CARTODB_ASSETS_HOST', "//#{CARTODB_DOMAIN}")

  File.open(APP_ROOT.join('config/app_config.yml'), 'w') { |f| f.write(configs.to_yaml) }
EOF

echo "Setup config/database.yml"
ruby <<-EOF
  require 'yaml'
  require 'pathname'

  APP_ROOT = Pathname.new(ENV.fetch('APP_ROOT', '/app'))
  configs = YAML.load_file(APP_ROOT.join('config/database.yml.sample'))
  config  = configs['production']
  config['host'] = ENV.fetch('POSTGRES_HOST', 'db')
  config['port'] = ENV.fetch('POSTGRES_PORT', '5432')
  config['username'] = ENV.fetch('POSTGRES_USER', 'cartodb')
  config['password'] = ENV.fetch('POSTGRES_PASSWORD', 'cartodb')
  config['database'] = ENV.fetch('POSTGRES_DB', 'cartodb')

  File.open(APP_ROOT.join('config/database.yml'), 'w') { |f| f.write(configs.to_yaml) }
EOF

echo "Run APP"
exec "$@"
