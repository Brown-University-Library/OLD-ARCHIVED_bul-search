Brown implementation of Blacklight.

#Indexing data

We have customized `config/SolrMarc/index.properties` to use a record id of `id = 907a[1-8], first`.  This is because Brown's library system stores the unique bibliographic record number in the 907 field.

This means that the sample MARC records distributed with Blacklight won't load with the default schema.  Use local records instead.

 * rake solr:marc:index MARC_FILE=path/to/marc.mrc
