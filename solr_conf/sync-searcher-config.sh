#!/bin/bash

set -e
set -x

#Copy the searcher's/slave config to local dir to verify configuration.
cp solr_conf/$SOLR_CORE/conf/solrconfig-searcher.xml $SOLR_HOME/$SOLR_CORE/conf/solrconfig.xml

#http://localhost:8983/solr/admin/cores?action=RELOAD&core=core0
curl "$SOLR_BASE_URL/admin/cores?action=RELOAD&core=$SOLR_CORE"
