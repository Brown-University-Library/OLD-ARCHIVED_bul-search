#!/bin/sh
set -e

#run as
#time ./data/index_dir.sh /dock/josiahdata/data/ http://server.name.brown.edu:8081/solr/ rec_[0-9].mrc
#time ./data/index_dir.sh /dock/josiahdata/data/ http://server.name.brown.edu:8081/solr/ rec_[0-9][0-9].mrc


HOME=$1

if [ $2 ]
then
    SOLR_URL=$2
else
    SOLR_URL='http://localhost:8983/solr/blacklight-core'
fi

if [ $3 ]
then
    PATTERN=$3
else
    PATTERN="*mrc"
fi

echo "Solr $SOLR_URL"


for file in $HOME/$PATTERN
do
    echo "Scanning $file for updates."
    rake solr:marc:index SOLR_MARC_MEM_ARGS=-Xmx2048m MARC_FILE=$file SOLR_URL=$SOLR_URL
done
