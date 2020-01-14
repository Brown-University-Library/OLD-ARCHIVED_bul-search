require "./app/models/solr_compare.rb"

# These tasks are used to compare the results of running a search
# against Solr 4 and Solr 7. The assume that the searches table
# has data to compare.
#
# ====================
# The process to import searches so that we can replay them is
# more or less as follows:
#
# Export MySQL searches table from production into a TSV file:
#
#     mysql -h servername -D dbname -u username -p -e "select * from searches" > searches.tsv
#     zip searches.zip searches.tsv
#
# Get the file to local machine and adjust encoding:
#
#     scp production:/opt/local/bul-search/searches.zip
#     unzip searches.zip
#     iconv -f ISO-8859-1 -t UTF8-MAC searches.tsv > searches.ok.tsv
#
# Import the file into local MySQL:
#
#     mysql -u root -D bul_search_dev;
#     mysql> delete from searches;
#     mysql> show variables like "local_infile";
#     mysql> set global local_infile = 1;
#     mysql> LOAD DATA LOCAL INFILE '/Users/hectorcorrea/dev/bul-search-src/searches.ok.tsv'
#            INTO TABLE searches FIELDS TERMINATED BY '\t'
#            ENCLOSED BY '"'
#            LINES TERMINATED BY '\n' IGNORE 1 ROWS;
# ====================

namespace :josiah do
    # Runs the first N searches from the searches table against Solr 4
    # and Solr 7 and compares the results.
    desc "Compares Solr search results for the first X number of searches"
    task "solr_compare" => :environment do |_cmd, args|
        solr = SolrCompare.new()
        results = solr.compare(30000)
        results.each do |result|
            puts result
        end
    end

    # Compares the result of a particular search (by ID) between Solr 4 and Solr 7.
    desc "Compares Solr search results for a given search ID"
    task "solr_compare_by_id" => :environment do |_cmd, args|
        solr = SolrCompare.new()
        results = solr.compare_by_id(17781970)
        results.each do |result|
            puts result
        end
    end
  end
