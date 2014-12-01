#!/bin/sh
set -e

git pull
bundle install
touch tmp/restart.txt
