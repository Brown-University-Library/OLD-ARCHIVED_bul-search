#!/bin/sh
set -e
git pull
RAILS_ENV=production bundle install --without development test
RAILS_ENV=production bundle exec rake assets:precompile
touch tmp/restart.txt
