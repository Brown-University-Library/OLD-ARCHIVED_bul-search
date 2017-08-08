#!/bin/sh
set -e
git pull
RAILS_ENV=production bundle install --without development test
RAILS_ENV=production bundle exec rake db:migrate

# In dev server use
# RAILS_ENV=production bundle exec rake assets:precompile RAILS_RELATIVE_URL_ROOT=/find
# to make sure the /find path is considered when compiling assets.
RAILS_ENV=production bundle exec rake assets:precompile

#rm -rf tmp/cache
touch tmp/restart.txt
