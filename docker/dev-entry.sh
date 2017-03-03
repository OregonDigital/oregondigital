#!/usr/bin/env bash

# If set_content isn't a directory, recursively copy whatever was built in the
# container
if [[ -L /oregondigital/set_content ]]; then
  rm -f /oregondigital/set_content
fi
if [[ ! -d /oregondigital/set_content ]]; then
  cp -r /opt/od_set_content /oregondigital/set_content
fi

# Sync set content, run database migrations, and create an admin user if this
# is our first run.  This might re-run these tasks unnecessarily, since db and
# set content are mounted in and the container may be removed between
# development sessions, but none of the tasks should hurt anything.  It just
# slows down the first run a bit.
if [[ -f /var/firstrun ]]; then
  bundle exec rake db:migrate
  bundle exec rake admin_user
  bundle exec rake sets:content:sync
  /bin/rm /var/firstrun
fi

# Start up puma
rm -f /oregondigital/tmp/pids/server.pid
bundle exec rails s -p 3000 -b "0.0.0.0"
