#!/bin/bash

set -e
set -x

#Pull from ENV variables
#SOLR_HOME
#SOLR_URL
#CORE
rsync -avz solr_conf/$SOLR_CORE/ $SOLR_HOME/$SOLR_CORE/

#http://localhost:8983/solr/admin/cores?action=RELOAD&core=core0
curl "$SOLR_BASE_URL/admin/cores?action=RELOAD&core=$SOLR_CORE"
