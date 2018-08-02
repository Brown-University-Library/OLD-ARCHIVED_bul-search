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

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'blacklight', "~> 5.13"
gem 'blacklight_advanced_search', '~> 5.0'

gem "jettywrapper", "~> 1.7"
gem "devise"
gem "devise-guests", "~> 0.3"
gem "omniauth"
gem "omniauth-shibboleth"
gem "blacklight-marc", "~> 5.10"
gem "blacklight_range_limit"

gem "font-awesome-rails"

group :development do
  gem "byebug"                # debugger
  gem "better_errors"         # web page for errors
  gem "binding_of_caller"     # allows inspecting values in web error page
end

gem 'handlebars_assets'

group :production do
  # Rails 4.x must stay within MySQL 0.4
  # https://github.com/brianmario/mysql2/issues/950#issuecomment-376375844
  gem 'mysql2', '< 0.5'
end

gem "rspec-rails", :group => [:development, :test]

# gem "bulmarc", :git => 'git@bitbucket.org:bul/bulmarc.git', :branch => 'master'
gem "bulmarc", :git => 'https://bitbucket.org/bul/bulmarc.git', :branch => 'master'

gem "http_logger", :group => [:development]

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

gem 'openurl', '~> 1.0.0'

# Needed for rails console in Ubuntu
gem "rb-readline"

gem "dotenv"
gem "ebsco-eds", :git => 'https://github.com/Brown-University-Library/edsapi-ruby.git'
