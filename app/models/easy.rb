require 'json'
require 'open-uri'
require 'summon'
require 'rsolr'
require 'uri'

class Easy
    def initialize source, query
        if source == 'summon'
          summon_rsp = get_summon query
          @results = summon_rsp['response']
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

def bdr_thumbnail id
  url = ENV['BDR_THUMBNAIL_SERVICE']
  "#{url}/#{id}"
end

def get_bdr query
  solr_url = ENV['BDR_SEARCH_URL']
  solr = RSolr.connect :url => solr_url

  qp = {
      :wt=>:json,
      "fl"=>"id:pid, title:primary_title, thumb:thumbnail",
      "q"=>"#{query}"
  }
  response = solr.get 'select', :params => qp
  response.deep_stringify_keys!


  response['response']['docs'].each do |doc|
    doc['link'] = bdr_link doc['id']
    doc['thumbnail'] = bdr_thumbnail doc['id']
  end
  response['response']
end

def easy_base_url
  ENV['BASE_URL'] + '/easy/'
end

def catalog_base_url
  #Rails.application.config.relative_url_root if Rails.application.config.respond_to?('relative_url_root')
  ENV['BASE_URL'] + '/catalog/'
end

def summon_url query
  return "http://brown.preview.summon.serialssolutions.com/#!/search?ho=t&fvf=ContentType,Journal%20Article,f%7CIsScholarly,true,f&l=en&q=#{query}"
end

def catalog_link id
  burl = catalog_base_url
  #cpath = Rails.application.routes.url_helpers.catalog_path(id)
  return burl + id
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
      "fl"=>"id, title_display, author_display, pub_date, format, online",
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
          doc['link'] = catalog_link doc['id']
          #Don't show pub_dates for Journals.  Not relevant.
          if format == 'Journal'
            doc.delete('pub_date')
          end
          #Take first value of pub_date
          if doc.has_key?("pub_date")
            doc['pub_date'] = doc['pub_date'][0]
          end
          grp_h['docs'] << doc
      end
      #Link to more results.
      cat_url = catalog_base_url
      enc_format = URI.escape(format)
      grp_h['more'] = "#{cat_url}?f[format][]=#{enc_format}&q=#{query}"
      groups << grp_h
  end

  out_data['groups'] = groups

  formats = []
  response['facet_counts']['facet_fields']['format'].each_slice(2) do |fgrp|
      (format, count) = fgrp
      #Link to more results.
      cat_url = catalog_base_url
      enc_format = URI.escape(format)
      d = {
          'format'=>format,
          'count'=>count,
          'more'=>"#{cat_url}?f[format][]=#{enc_format}&q=#{query}"
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
    "s.ps" => 5,
    "s.hl" => false,
  )

  results = Hash.new
  results_docs = Array.new

  search.documents.each do |doc|
    d = Hash.new
    d['id'] = doc.id
    d['title'] = doc.title
    d['link'] = doc.link
    d['year'] = doc.publication_date.year
    doc.authors.each do |au|
      d['author'] = au.fullname
      break
    end
    d['venue'] = doc.publication_title  if doc.respond_to?('publication_title')
    d['volume'] = doc.volume  if doc.respond_to?('volume')
    d['issue'] = doc.issue  if doc.respond_to?('issue')
    d['start'] = doc.start_page  if doc.respond_to?('start_page')
    results_docs << d
  end

  results['response'] = Hash.new
  results['response']['more'] = summon_url(query)
  results['response']['docs'] = results_docs
  results['response']['numFound'] = search.record_count
  return results
end
