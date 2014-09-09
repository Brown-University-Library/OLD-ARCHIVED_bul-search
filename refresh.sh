#!/bin/sh
set -e

chruby ruby-2
git pull
bundle install
touch tmp/restart.txt
