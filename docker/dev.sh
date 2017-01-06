#!/usr/bin/env bash
#
# This script is primarily just for demonstrating what needs to happen to get
# set up.  Some things may need to be tweaked, such as only migrating once.
# Feel free to copy this to create your own docker-compose adventure!

# Stop everything
docker-compose stop

# Build, migrate, and clean up
docker build --rm -t oregondigital/od1 -f docker/Dockerfile-dev .
docker-compose run web bundle exec rake db:migrate
docker-compose rm -f web
docker-compose rm -f workers
docker-compose rm -f resquehead

# Restart
docker-compose up
