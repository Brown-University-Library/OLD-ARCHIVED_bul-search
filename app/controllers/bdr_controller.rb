# -*- encoding : utf-8 -*-
#
require 'blacklight/catalog'

class BdrController < ApplicationController  

  include Blacklight::Catalog
  #include BlacklightAdvancedSearch::ParseBasicQ

  configure_blacklight do |config|
    # solr path which will be added to solr base url before the other solr params.
    config.solr_path = 'search'

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      :qt => 'search',
      :rows => 10,
      :fl => 'id:pid,*',
      :facet => 'true',
      'facet.mincount' => 1,
      'fq' => 'discover:BDR_PUBLIC',
    }

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
      :qt => 'search',
      :fl => 'id:pid,*',
      :rows => 1,
      :q => '{!raw f=pid v=$id}' 
    }

    # solr field configuration for search results/index views
    config.index.title_field = 'primary_title'
    config.index.display_type_field = 'object_type'

    # solr field configuration for document/show views
    config.show.title_field = 'primary_title'
    config.show.display_type_field = 'object_type'

    config.show.route = {:controller => :current}

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    #
    # :show may be set to false if you don't want the facet to be drawn in the 
    # facet bar

    config.add_facet_field 'ir_collection_name', :label => 'Collection'
    config.add_facet_field 'genre_local', :label => 'Genre'
    config.add_facet_field 'keyword', :label => 'Keywords'
    config.add_facet_field 'mods_type_of_resource', :label => 'Format'

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field 'primary_title', :label => 'Title:' 
    config.add_index_field 'contributor_display', :label => 'People and Places:' 
    config.add_index_field 'genre', :label => 'Genre:' 
    config.add_index_field 'ir_collection_name', :label => 'Collection Title:' 
    config.add_index_field 'abstract', :label => 'Description:' 
    config.add_index_field 'keyword', :label => 'Keywords:'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    config.add_show_field 'primary_title', :label => 'Title:' 
    config.add_show_field 'contributor_display', :label => 'Contributor:' 
    config.add_show_field 'object_type', :label => 'Object Type:' 

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different. 

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise. 
    
    config.add_search_field 'text', :label => 'All Fields'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    
    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params. 
      #field.solr_parameters = { :'spellcheck.dictionary' => 'primary_title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = { 
        :type => 'dismax',
        :qf => 'all_titles',
        #:pf => '$title_pf'
      }
    end
    
    config.add_search_field('subject') do |field|
      field.solr_local_parameters = { 
        :type => 'dismax',
        :qf => 'all_subjects',
        #:pf => '$title_pf'
      }
    end
    
    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_ssort asc', :label => 'relevance'
    #config.add_sort_field 'pub_date_sort desc, title_sort asc', :label => 'year'
    #config.add_sort_field 'author_sort asc, title_sort asc', :label => 'author'
    config.add_sort_field 'title_ssort asc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  def blacklight_solr_config
    {url: ENV['BDR_SOLR_URL']}
  end

end 
