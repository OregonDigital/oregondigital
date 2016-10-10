#!/bin/bash

# Modified from solr-precreate task in distribution's script
CORE=development
CONFIG_SOURCE="/opt/solr/server/solr/configsets/data_driven_schema_configs"
coresdir="/opt/solr/server/solr/mycores"
mkdir -p $coresdir
coredir="$coresdir/$CORE"
if [[ ! -d $coredir ]]; then
    cp -r $CONFIG_SOURCE/ $coredir
    touch "$coredir/core.properties"
    echo created "$CORE"
else
    echo "core $CORE already exists"
fi

# Override stuff with OD files
rm -f $coredir/conf/managed-schema
cp /var/odconf/schema.xml $coredir/conf/schema.xml
cp /var/odconf/solrconfig.xml $coredir/conf/solrconfig.xml
