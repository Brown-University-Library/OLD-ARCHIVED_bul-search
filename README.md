Brown University Library discovery tool. This is a Blacklight application that integrates data from our catalog (Sierra), journals (via EBSCO), and Brown's institutional repository (BDR) into a single discovery interface.


## Pre-requisites
If you are new to Blacklight, read the [Blacklight Quickstart](https://github.com/projectblacklight/blacklight/wiki/Quickstart) to become familiar with the project. We are using Blacklight 5.x

Download and install Ruby 2.3.5:
```
brew install ruby-install
brew install chruby
ruby-install ruby 2.3.5
chruby 2.3.5
```

Download and install Solr 7, create a Solr core for our data, and customize the schema for this project (via the script in bul-traject)
```
cd
curl http://archive.apache.org/dist/lucene/solr/7.5.0/solr-7.5.0.zip > solr-7.5.0.zip
unzip solr-7.5.0.zip
cd ./solr-7.5.0/bin
./solr start
./solr create -c josiah7

curl https://raw.githubusercontent.com/Brown-University-Library/bul-traject/master/solr7/define_schema.sh > define_schema.sh
chmod u+x define_schema.sh
./define_schema.sh
```


## Installation

Download and install the source code:
```
cd
git clone https://github.com/Brown-University-Library/bul-search.git
cd bul-search
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
```

Update the `.env` file to point to your Solr URL
```
echo "export SOLR_URL=http://localhost:8983/solr/josiah7" >> .env
```

Running the application
```
bundle exec rails server
```

Visit the catalog at http://localhost:3000/catalog


## Sample Records
We use `traject` to import data into Solr. You can mimic our setup by using `traject` in your local environment as follows:

```
# Get the code for our traject project
cd
git clone https://github.com/Brown-University-Library/bul-traject.git
cd bul-traject
bundle install

# Import a sample file
bundle exec traject -c config.rb -u http://localhost:8983/solr/josiah7 /path/to/bul-search/data/bul_sample.mrc

# Commit the data to Solr
curl "http://localhost:8983/solr/josiah7/update?commit=true"

# Confirm there is data in Solr
curl "http://localhost:8983/solr/josiah7/select?q=*%3A*&wt=json&indent=true"
```

You can pass the `--debug-mode` flag to Traject if you just want to see what will be imported but not import it to Solr.


## Sample Records (without Traject)
If you want to skip Traject for testing purposes you can use the Solr `post` utility to import the sample data directly into Solr:

```
cd bul-search
post -c josiah7 ./data/bul_sample.json
```


## Unit tests
There is a rudimentary set of tests to validate a few classes. Take a look at the `./test` folder or you can run them via:

```
bundle exec rake josiah:tests
```


## schema.rb
By default the development environment uses MySQL so that it matches with what
we use in production. If you switch to SQLite for development (by updating
`config/database.yml`) beware that you might get a slightly different
`schema.rb` file after running `rake db:migrate`. You should discard those
changes  with `git checkout -- schema.rb` so that you don't accidentally
commit them to the repository.


## Articles (EDS)
If you wish to include articles in the results you will need to set the following settings in your `.env` file:

```
EDS_CACHE_SESSION=true-or-false
EDS_PROFILE_ID=your-profile-id
EDS_USER_ID=your-user
EDS_PASSWORD=your-password
```


## Bento Box
The working name for this app/project is `easySearch`.

Locally the Bento Box is available at: `http://localhost:3000/easy/`

At present, the Bento Box queries EDS and the local Solr index for data.

The model code is in `app/models/easy.rb` and the JavaScript for now is in `app/views/easy/home.html.erb`.
