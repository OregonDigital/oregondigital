#!/usr/bin/env bash
#
# This script is primarily just for demonstrating what needs to happen to get
# set up.  Some things may need to be tweaked, such as only migrating once.
# Feel free to copy this to create your own docker-compose adventure!

# Stop and clean up everything
docker-compose down

# Pull images from dockerhub; nothing happens if you already have these
docker pull oregondigital/od1
docker pull oregondigital/solr
docker pull oregondigital/phantomjs:1.8.1
docker pull oregondigital/hydra-jetty:3.8.1-4.0

# Rebuild the od1 dev container in case of code changes
docker-compose build web

# Run migrations
docker-compose run workers bundle exec rake db:migrate

# Restart in the background
docker-compose up -d

# Follow the web logs
docker-compose logs -f web
