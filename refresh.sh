#!/bin/sh
set -e
git pull
RAILS_ENV=production bundle install --without development test
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake assets:precompile
# sudo chown -R blacklight.libstaff /opt/local/bul-search-src/public/assets/
# sudo chown -R blacklight.libstaff /opt/local/bul-search-src/tmp/
touch tmp/restart.txt
