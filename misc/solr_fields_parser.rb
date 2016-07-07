# Parses a JSON file with Solr field information
# and outputs a comma/tab separated list of fields
# and their specs (indexed, stored, et cetera)
#
# Usage: Fetch JSON field details from Solr via:
#   curl "http://localhost:8081/solr/blacklight-core/admin/luke?numTerms=0&wt=json" > solr_fields.json
#
# then run it through this program via:
#   ruby solr_fields_parser.js solr_fields.json > solr_fields.csv
#

require "json"
if ARGV.count == 0
  abort "Must provide a JSON file with the data"
end

text = File.read(ARGV[0])
json = JSON.parse(text)
sep = "\t"

json["fields"].each do |key, value|
  puts "#{key}#{sep}#{value['type']}#{sep}#{value['schema']}#{sep}#{value['dynamicBase']}#{sep}#{value['index']}"
end
