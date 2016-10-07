# Creates an image suitable for running Solr in a way that works with OD 1
#
# Build:
#     docker build --rm -t oregondigital/solr -f docker/Dockerfile-solr .
FROM solr:6-alpine
MAINTAINER Jeremy Echols <jechols@uoregon.edu>
COPY solr_conf/conf_v6 /var/odconf
COPY docker/solrsetup.sh /docker-entrypoint-initdb.d/odsetup.sh
