require 'json'
require 'open-uri'
require 'summon'
require 'rsolr'

class Easy
    def initialize source, query
        if source == 'summon'
          summon_rsp = get_summon query
          @results = summon_rsp['response']['docs']
        elsif source == 'bdr'
          @results = get_bdr query
        else
          @results = get_cat query
        end
    end

    def to_json
        @results
    end
end

def bdr_link id
  item_url = ENV['BDR_ITEM_URL']
  "#{item_url}/#{id}/"
end

def get_bdr query
  solr_url = ENV['BDR_SEARCH_URL']
  solr = RSolr.connect :url => solr_url

  qp = {
      :wt=>:json,
      "fl"=>"id:pid, title:primary_title",
      "q"=>"#{query}"
  }
  response = solr.get 'select', :params => qp
  response.deep_stringify_keys!


  response['response']['docs'].each do |doc|
    doc['link'] = bdr_link doc['id']
  end
  response['response']
end

def catalog_link id
  "/catalog/#{id}"
end

def get_cat query
  solr_url = ENV['SOLR_URL']

  solr = RSolr.connect :url => solr_url

  qp = {
      :defType=>"edismax",
      "group.ngroups"=>true,
      "group.field"=>"format",
      "group"=>true,
      "group.limit"=>5,
      "fl"=>"id, title_display",
      "q"=>"#{query}"
  }

  response = response = solr.get 'select', :params => qp

  out_data = {}

  groups = []

  response['grouped']['format']['groups'].each do |grp|
      format = grp['groupValue']
      grp_h = {}
      grp_h['format'] = format
      grp_h['numFound'] = grp['doclist']['numFound']
      grp_h['docs'] = []
      grp['doclist']['docs'].each do |doc|
          d = {
              'id'=>doc['id'],
              'title'=>doc['title_display'],
          }
          d['link'] = catalog_link doc['id']
          grp_h['docs'] << d
      end
      groups << grp_h
  end

  out_data['groups'] = groups

  formats = []
  response['facet_counts']['facet_fields']['format'].each_slice(2) do |fgrp|
      (format, count) = fgrp
      d = {
          'format'=>format,
          'count'=>count
      }
      formats << d
  end

  out_data['formats'] = formats

  return out_data
end

def get_summon query
  aid = ENV['SUMMON_ID']
  akey = ENV['SUMMON_KEY']

  @service = Summon::Service.new(:access_id=>aid, :secret_key=>akey)
  search = @service.search(
    "s.q" => "#{query}",
    "s.fvf" => "ContentType,Journal Article",
    "s.cmd" => "addFacetValueFilters(IsScholarly, true)",
    "s.ho" => "t",
    "s.ps" => 5
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
  return results
end
