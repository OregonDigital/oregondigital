#!/usr/bin/env bash
#
# Simplify testing with careful wrapping of test stuff

# Need to debug?  Try this handy alias:
#
# alias dctest="docker-compose -p ODTEST -f test-compose.yaml"

dctest() {
  docker-compose -p ODTEST -f test-compose.yaml $@
}

# Rebuild the OD images just so we know it's good to go with whatever changes
# we've made last
dctest build od
dctest build test

# Test containers aren't important and can just be destroyed as needed
if [[ $1 == "--destroy" ]]; then
  dctest kill
  dctest rm -f
  shift
fi

# Start services one at a time so we can watch the actual test output properly.
# We should probably reconsider using compose for testing, but meh....
dctest create
dctest start fc381
dctest start memcached
dctest start redis
dctest start mongo
dctest start solr
dctest run phantomjs

# Fedora is the slow one, so we wait until we get a response
echo "Waiting for Fedora to start"
while true; do
  curl -s http://127.0.0.1:18983 >/dev/null && break
  sleep 0.1
done

target=${@:-spec/}
# Run tests!
echo "Running 'bundle exec rspec $target'"
dctest run test bundle exec rspec $target
