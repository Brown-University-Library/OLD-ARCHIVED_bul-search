source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', :group => [:development, :test]

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

gem 'blacklight', "~> 5.13"
gem 'blacklight_advanced_search', '~> 5.0'

gem "jettywrapper", "~> 1.7"
gem "devise"
gem "devise-guests", "~> 0.3"
gem "omniauth"
gem "omniauth-shibboleth"
gem "blacklight-marc", "~> 5.10"
gem "blacklight_range_limit"
#gem "blacklight-marc", :path => "/work/blacklight_marc"
#gem "blacklight-marc", :git => 'https://github.com/lawlesst/blacklight_marc.git', :branch => 'marc-in-json'

gem "summon", "~> 2.0.5"

gem "font-awesome-rails"

group :development do
  gem "byebug"                # debugger
  gem "better_errors"         # web page for errors
  gem "binding_of_caller"     # allows inspecting values in web error page
end

gem 'handlebars_assets'

gem 'mysql2', :group => [:production]

gem "rspec-rails", :group => [:development, :test]

#gem "bulmarc", :path => "/work/bul_marc_utils"
gem "bulmarc", :git => 'git@bitbucket.org:bul/bulmarc.git', :branch => 'master'

gem "http_logger", :group => [:development]

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

gem 'openurl', '~> 1.0.0'

# Needed for rails console in Ubuntu
gem "rb-readline"

gem "dotenv"
gem "ebsco-eds", :git => 'https://github.com/Brown-University-Library/edsapi-ruby.git'
# gem "ebsco-eds", path: "/Users/hectorcorrea/dev/edsapi-ruby"
