#!/usr/bin/env bash
bundle exec rake default_thumbs_init
# run tests
bundle exec rspec $@
