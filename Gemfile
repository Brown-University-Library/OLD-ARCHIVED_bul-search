source 'https://rubygems.org'

gem 'rails', '~> 4.2.11'

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

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'blacklight', "~> 5.13"
gem 'blacklight_advanced_search', '~> 5.0'

gem "jettywrapper", "~> 1.7"

# Gems forced to a specific version to address security vulnerabilities
gem "devise", ">= 4.7.1"
gem "devise-guests", "~> 0.3"
gem "omniauth"
gem "omniauth-shibboleth"
gem "nokogiri", ">= 1.10.4"
gem "blacklight-marc", "~> 5.10"
gem "blacklight_range_limit"

gem "font-awesome-rails"

group :development do
  gem "byebug"                # debugger
  gem "better_errors"         # web page for errors
  gem "binding_of_caller"     # allows inspecting values in web error page
end

gem 'handlebars_assets'

# Older versions have a security vulnerability
gem "bootstrap-sass", ">= 3.4.1"

# For dev and testing you can use sqlite3 with the following command
#   gem 'sqlite3', :group => [:development, :test]
#
# Rails 4.x must stay within MySQL 0.4
# https://github.com/brianmario/mysql2/issues/950#issuecomment-376375844
gem 'mysql2', '< 0.5'

# gem "bulmarc", :git => 'git@bitbucket.org:bul/bulmarc.git', :branch => 'master'
gem "bulmarc", :git => 'https://bitbucket.org/bul/bulmarc.git', :branch => 'master'

gem "http_logger", :group => [:development]

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

gem 'openurl', '~> 1.0.0'

# Needed for rails console in Ubuntu
gem "rb-readline"

gem "dotenv"
gem "ebsco-eds", :git => 'https://github.com/Brown-University-Library/edsapi-ruby.git'

# Use this when troubleshooting raw (HTTP) queries to Solr.
# gem 'net-http-spy'

gem "solr_lite", '0.0.17'
# gem "solr_lite", path: '/Users/hectorcorrea/dev/solr_lite'

gem "lcsort", '0.9.1'