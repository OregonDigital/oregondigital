#!/usr/bin/env bash

# Re-link the set content, since dev will mount in local directories
/bin/rm -f /oregondigital/set_content
/bin/ln -s /opt/od_set_content /oregondigital/set_content
/link-set-content.sh

# Run database migrations and create an admin user if this is our first run.
# This might re-run both tasks on one's local database, since db is mounted in
# and the container may be removed between development sessions, but neither
# task should hurt anything.  It just slows down the first run a bit.
if [[ -f /var/firstrun ]]; then
  bundle exec rake db:migrate
  bundle exec rake admin_user
  /bin/rm /var/firstrun
fi

# Start up puma
rm -f /oregondigital/tmp/pids/server.pid
bundle exec rails s -p 3000 -b "0.0.0.0"
