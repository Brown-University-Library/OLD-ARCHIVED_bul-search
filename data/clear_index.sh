#!/bin/sh

SOLR_URL='http://localhost:8081/solr/blacklight-core'

curl $SOLR_URL/update?commit=true -H "Content-Type: text/xml" --data-binary '<delete><query>*:*</query></delete>'
