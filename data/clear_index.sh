#!/bin/sh
curl $SOLR_URL/update?commit=true -H "Content-Type: text/xml" --data-binary '<delete><query>*:*</query></delete>'
