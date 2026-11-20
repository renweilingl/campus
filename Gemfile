source "https://rubygems.org"

ruby "3.3.3"

gem "rails", "~> 8.1.0"

# 资源管线用 propshaft，对应 layout 里的 stylesheet_link_tag :app
gem "propshaft"

gem "mysql2", "~> 0.5"

gem "puma", ">= 5.0"

# ApplicationController 用了 stale_when_importmap_changes，由 importmap-rails 提供
gem "importmap-rails"
gem "turbo-rails"

gem "jbuilder"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Docker 部署，Dockerfile / bin/thrust / config/deploy.yml 依赖
gem "kamal", require: false
gem "thruster", require: false

# Active Storage 图片变体
gem "image_processing", "~> 1.2"

# 认证 / 授权 / 审计
gem "sorcery"
gem "pundit"
gem "audited"
gem "oauth2"
gem "jwt"

# 异步任务 / Redis
gem "sidekiq", "~> 7.0"
gem "connection_pool", "~> 2.4"
gem "redis", "~> 4"
gem "redis-namespace"

# Grape API
gem "grape"
gem "grape-entity"
gem "grape_logging"
gem "grape_on_rails_routes"
gem "grape-swagger"
gem "grape-swagger-entity"
gem "grape-swagger-rails"

# 查询 / 分页
gem "ransack"
gem "will_paginate", "~> 4.0"

# HTTP / HTML / Markdown
gem "httparty"
gem "rest-client"
gem "nokogiri"
gem "redcarpet"
gem "coderay"

# Excel
gem "roo", "~> 2.8.0"
gem "simple_xlsx_reader"
gem "spreadsheet"

gem "net-ssh"
gem "dotenv"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem "carrierwave", "0.8.0"
gem 'carrierwave-aliyun', '~> 0.7.0'
