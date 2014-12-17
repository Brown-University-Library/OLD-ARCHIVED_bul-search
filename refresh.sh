#!/bin/sh
set -e

git pull
bundle install
RAILS_ENV=production bundle exec rake assets:precompile
touch tmp/restart.txt
