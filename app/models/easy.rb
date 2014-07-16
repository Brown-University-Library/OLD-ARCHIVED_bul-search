require 'json'
require 'open-uri'
require 'summon'

# class Easy
#   def initialize query
#     #get results from solr
#     resp = open("http://daxdev.services.brown.edu:8082/solr/fedora_solr/select/?q=#{query}&wt=json")
#     @results = JSON.parse resp.read
#   end

#   def to_json
#     @results['response']['docs'].to_json
#   end
# end


class Easy
    def initialize query
        aid = ENV['SUMMON_ID']
        akey = ENV['SUMMON_KEY']

        @service = Summon::Service.new(:access_id=>aid, :secret_key=>akey)
        search = @service.search(
          "s.q" => "#{query}",
          "s.fvf" => "ContentType,Journal Article",
          "s.cmd" => "addFacetValueFilters(IsScholarly, true)",
          "s.ho" => "t"
        )

        results = Hash.new
        results_docs = Array.new

        search.documents.each do |doc|
          d = Hash.new
          d['id'] = doc.id
          d['title'] = doc.title
          d['link'] = doc.link
          d['year'] = doc.publication_date.year
          results_docs << d
        end

        results['response'] = Hash.new
        results['response']['docs'] = results_docs
        @results = results
    end

    def to_json
        @results['response']['docs']
    end
end