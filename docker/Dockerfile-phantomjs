# Creates an image containing phantomjs 1.8.1 for the OD setup
#
# Build:
#     docker build --rm -t oregondigital/phantomjs -f docker/Dockerfile-phantomjs .

# TODO: Upgrade ubuntu when the dev setup upgrades!
FROM ubuntu:16.04
MAINTAINER Jeremy Echols <jechols@uoregon.edu>

# apt won't find some libs if this isn't run
RUN apt-get update

# PhantomJS dependencies
RUN apt-get install -y build-essential g++ flex bison gperf ruby perl \
  libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev \
  libpng-dev libjpeg-dev python libx11-dev libxext-dev

RUN apt-get install -y git
RUN git clone https://github.com/ariya/phantomjs/ /opt/phantomjs
WORKDIR /opt/phantomjs
RUN git checkout 1.8.1
RUN yes | ./build.sh
