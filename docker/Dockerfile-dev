# Creates an image suitable for running the Rails stack in development and
# testing.  You shouldn't push this image up, as it's concerned with making a
# local image based on your current code.  It will not reflect general needs.
#
# Build:
#     docker build --rm -t oregondigital/od1-dev -f docker/Dockerfile-dev .
FROM oregondigital/od1
MAINTAINER Jeremy Echols <jechols@uoregon.edu>

# ???? - docker won't remove or rewrite .bundle/config via RUN commands, so I
# just copy in an empty file.  No clue why this is giving me issues.
COPY docker/empty /oregondigital/.bundle/config
RUN bundle install

# Add the local Gemfiles over what's in the OD1 image and bundle install again.
# This seemingly-redundant step ensures that only the local changes are
# reinstalled when dependency changes occur locally, rather than having to
# re-pull all dev/test gems again.
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

RUN touch /var/firstrun
