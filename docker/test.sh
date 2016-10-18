#!/usr/bin/env bash
#
# Simplify testing with careful wrapping of test stuff

# Need to debug?  Try this handy alias:
#
# alias dctest="docker-compose -p ODTEST -f test-compose.yaml"

dctest() {
  docker-compose -p ODTEST -f test-compose.yaml $@
}

# Test containers aren't important and can just be destroyed as needed
if [[ $1 == "--destroy" ]]; then
  dctest kill
  dctest rm -f
  shift
fi

quick=0
if [[ $1 == "--quick" ]]; then
  quick=1
  shift
fi

# Start services one at a time so we can watch the actual test output properly.
dctest create
dctest start fc381
dctest start memcached
dctest start redis
dctest start mongo
dctest start solr

if [[ ! -f phantombin/phantomjs ]]; then
  dctest run phantomjs
  dctest rm -f phantomjs
fi

# Fedora is the slow one, so we wait until we get a response
echo "Waiting for Fedora to start"
while true; do
  curl -s http://127.0.0.1:18983 >/dev/null && break
  sleep 0.1
done

target=${@:-spec/}
# Run tests!
echo "Running 'bundle exec rspec $target'"
dctest run test $target

if [[ $quick == 0 ]]; then
  dctest stop
fi
