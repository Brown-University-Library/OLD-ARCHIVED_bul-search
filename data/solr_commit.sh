#!/bin/sh
curl $SOLR_URL/update --data-binary '<commit/>' -H "Content-type: text/xml"
