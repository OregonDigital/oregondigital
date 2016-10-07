# Creates an image suitable for running hydra-jetty with Solr 4.0 and Fedora
# Commons 3.8.1.  This is pretty dev-centric and may not be suitable for
# a production environment.
#
# Build:
#     docker build --rm -t oregondigital/hydra-jetty -f docker/Dockerfile-hydra-jetty .
FROM openjdk:8
MAINTAINER Jeremy Echols <jechols@uoregon.edu>

RUN apt-get update
RUN apt-get install -y git

# Grab the project we set up for OD to use Fedora 3.8.1 - this is a shallow
# clone so it won't be a 1-2 gig download, but it's still pretty big.
RUN git clone https://github.com/OregonDigital/hydra-jetty-fedora381.git /opt/jetty
WORKDIR /opt/jetty

# Default to starting the service
CMD java -Djetty.port=8983 -Dsolr.solr.home=/oregondigital/jetty/solr -XX:MaxPermSize=128m -Xmx256m -jar start.jar
