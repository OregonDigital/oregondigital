#!/usr/bin/env bash
#
# This script is primarily just for demonstrating what needs to happen to get
# set up.  Some things may need to be tweaked, such as only migrating once.
# Feel free to copy this to create your own docker-compose adventure!
./docker/compose stop web
./docker/compose rm -f web

docker build --rm -t oregondigital/od1 -f docker/Dockerfile-dev .
./docker/compose run web bundle exec rake db:migrate
./docker/compose start

# Need a shell in the web head?  Try this:
# docker-compose -f docker/docker-compose.dev.yaml run web bash
