Brown implementation of Blacklight.

#Installation

Read the [Blacklight Quickstart](https://github.com/projectblacklight/blacklight/wiki/Quickstart) to become famiilar with the project.  You might want to follow the steps locally and install a default Blacklight instance as a test project.

To install the Brown Blacklight code locally:

 * verify that you have the dependencies listed in the Quickstart.
 * check out the code.
 * cd into the code and run `bundle install`.
 * `rake db:migrate` to configure the db.
 * `rake jetty:start` to start Jetty and Solr.  Note the Solr port.  This needs to match the solr port in `config/jetty.yml`.
 * `rake solr:marc:index MARC_FILE=data/bul_sample.mrc` to index sample Brown records.
 * `rails server` to start rails in development mode
 * If all goes correctly: visit the catalog at http://localhost:3000/catalog.
 * A sample search of `atom` will return results from the sample set of MARC records.

#Environment setup
For development the [dotenv](https://github.com/bkeepers/dotenv) gem has been added.  Local settings can be set in the a `.env` file.  `sample-env` is included. Copy it to `.env` and adjust the values.

An additional rails environment has been created called `devbox`.  I created this because I want to run Rails on `dblightcit` in development mode for now.  I also have had trouble installing the `debugger` gem on the server.  So creating another environment for local gemsets seems to be a route to take.  You can follow this pattern as well or just the development Rails environment locally.

#Indexing data

We have customized `config/SolrMarc/index.properties` to use a record id of `id = 907a[1-8], first`.  This is because Brown's library system stores the unique bibliographic record number in the 907 field.

This means that the sample MARC records distributed with Blacklight won't load with the default schema.

A sample set of 31 MARC records are included in the data/ directory.

These records can be indexed with:

 * `rake solr:marc:index MARC_FILE=data/bul_sample.mrc`

A sample search of `atomic` will return results.


#Bento Box
Work towards a Bento Box search is at: http://dblightcit.services.brown.edu/find/easy/

Locally the Bento Box is available at: `http://localhost:3000/easy/?q=rdf%20python`
