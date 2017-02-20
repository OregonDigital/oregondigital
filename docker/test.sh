#!/usr/bin/env bash
#
# Simplify testing with careful wrapping of test stuff

# Need to debug?  Try this handy alias:
#
# alias dctest="docker-compose -p ODTEST -f test-compose.yaml"

dctest="docker-compose -p ODTEST -f test-compose.yaml"

# Default to not shutting down services after testing
quick=1

dcrun() {
  $dctest run --rm --entrypoint="$1" test
}

# Test containers aren't important and can just be destroyed as needed
if [[ $1 == "--destroy" ]]; then
  $dctest kill
  $dctest rm -f
  $dctest down
  $dctest build test
  quick=0
  shift
fi

# Start services separately so we can watch the actual test output properly.
$dctest up -d fc381 memcached redis mongo solr

if [[ ! -f phantombin/phantomjs ]]; then
  $dctest run --rm phantomjs
  $dctest rm -f phantomjs
fi

# Fedora is the slow one, so we wait until we get a response
echo "Waiting for Fedora to start"
while true; do
  curl -s http://127.0.0.1:18983 >/dev/null && break
  sleep 0.1
done

# Destroy screenshots so whatever is in the dir is from the latest run
dcrun "rm -f /oregondigital/log/test.log"
dcrun "find /oregondigital/tmp/capybara -type f -exec rm {} \\;"

# Unless "quick" is explicitly requested, we need to make sure the test
# database is prepared.  This is painfully slow on post-setup runs, but it
# ensures tests are always coming from a sane start, and avoids very painful
# debugging when the schema changes.
if [[ $quick == 0 ]]; then
  dcrun "rm -f /oregondigital/db/test.db"
  dcrun "bundle exec rake db:migrate"
fi

target=${@:-spec/}
# Run tests!
echo "Running 'bundle exec rspec $target'"
$dctest run --rm test $target

if [[ $quick == 0 ]]; then
  $dctest stop
else
  echo "If you wish to stop and destroy all test containers, run this:"
  echo "    $dctest stop"
  echo "    $dctest rm"
fi
