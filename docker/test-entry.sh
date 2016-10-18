#!/usr/bin/env bash

# Re-link the set content, since dev will mount in local directories
/bin/rm -f /oregondigital/set_content
/bin/ln -s /opt/od_set_content /oregondigital/set_content
/link-set-content.sh

# run tests
bundle exec rspec $@
