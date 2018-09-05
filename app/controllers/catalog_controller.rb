# -*- encoding : utf-8 -*-
#
class CatalogController < ApplicationController
  include Blacklight::Marc::Catalog
  include Blacklight::Catalog
  include Blacklight::BlacklightHelperBehavior  # gives us document_partial_name(), used in ourl_service()

  include ApplicationHelper

  before_filter :set_easy_search

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      :qt => 'search',
      :rows => 10,
      :spellcheck => false
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}'
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

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
    config.add_facet_field 'access_facet', :label => 'Access', :collapse => false
    config.add_facet_field 'format', :label => 'Format', :limit => true, :collapse => false
    config.add_facet_field 'author_facet', :label => 'Author', :limit => 20
    #config.add_facet_field 'pub_date', :label => 'Publication Year', :limit => 20, :sort => 'index', :collapse => false
    config.add_facet_field 'pub_date', :label => 'Publication Year', :range => true
    # config.add_facet_field 'pub_date_sort', :label => 'Publish Date', :query => {
    #   :years_5 => { :label => 'within 5 Years', :fq => "pub_date:[#{Time.now.year - 5 } TO *]" },
    #   :years_10 => { :label => 'within 10 Years', :fq => "pub_date:[#{Time.now.year - 10 } TO *]" },
    #   :years_25 => { :label => 'within 25 Years', :fq => "pub_date:[#{Time.now.year - 25 } TO *]" },
    #   :years_more => { :label => 'older than 25 Years', :fq => "pub_date:[#{Time.now.year - 26 } TO *]" }
    # }

    config.add_facet_field 'topic_facet', :label => 'Topic', :limit => 20
    config.add_facet_field 'region_facet', :label => 'Topic: Region', :limit => 20
    config.add_facet_field 'language_facet', :label => 'Language', :limit => 20
    config.add_facet_field 'building_facet', :label => 'Location'

    #config.add_facet_field 'lc_1letter_facet', :label => 'Call Number'
    #config.add_facet_field 'subject_geo_facet', :label => 'Region'
    #config.add_facet_field 'subject_era_facet', :label => 'Era'

    #config.add_facet_field 'example_pivot_field', :label => 'Pivot Field', :pivot => ['format', 'language_facet']



    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    #config.add_index_field 'title_display', :label => 'Title'
    config.add_index_field 'title_vern_display', :label => 'Title'
    #config.add_index_field 'author_vern_display', :label => 'Author'
    #config.add_index_field 'format', :label => 'Format'
    #config.add_index_field 'language_facet', :label => 'Language'
    #config.add_index_field 'published_display', :label => 'Published'
    #config.add_index_field 'published_vern_display', :label => 'Published'
    #config.add_index_field 'lc_callnum_display', :label => 'Call number'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    #config.add_show_field 'title_display', :label => 'Title'
    #config.add_show_field 'title_vern_display', :label => 'Title'
    #config.add_show_field 'abstract_display', :label => 'Abstract/summary'
    config.add_show_field 'format', :label => 'Format', :show_icon => true
    config.add_show_field 'license_agreements', :label => 'x' # calculated, not in Solr
    config.add_show_field 'subtitle_display', :label => 'Subtitle'
    config.add_show_field 'subtitle_vern_display', :label => 'Subtitle'
    config.add_show_field 'author_display', :label => 'Author', :linked_fielded_search => 'author'
    config.add_show_field 'author_vern_display', :label => 'Author'
    config.add_show_field 'author_addl_display', :label => 'Other Author', :linked_fielded_search => 'author', :multi => true
    config.add_show_field 'marc_subjects', :label => 'Subject', :hot_link => true, :doc_key => 'marc_subjects', :index => 'subject'
    #config.add_show_field 'other_authors', :label => 'Other Author', :hot_link => true, :doc_Key => 'marc_additional_authors', :index => 'author'
    config.add_show_field 'pub_date', :label => 'Publication Year'
    config.add_show_field "subject_topic_facet", :label => 'Subject'
    config.add_show_field 'language_facet', :label => 'Language'
    config.add_show_field 'published_display', :label => 'Published'
    config.add_show_field 'published_vern_display', :label => 'Published'
    config.add_show_field 'physical_display', :label => "Physical Description"
    #config.add_show_field 'toc_display', :label => 'Contents'
    config.add_show_field 'isbn_t', :label => 'ISBN'
    config.add_show_field 'issn_t', :label => 'ISSN'
    config.add_show_field 'oclc_t', :label => 'OCLC'

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

    config.add_search_field 'all_fields', :label => 'All Fields'


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end

    config.add_search_field('author') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = {
        :qf => '$author_qf',
        :pf => '$author_pf'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.qt = 'search'
      field.solr_local_parameters = {
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_sort desc, title_sort asc', :label => 'relevance'
    config.add_sort_field 'pub_date_sort desc, title_sort asc', :label => 'year'
    config.add_sort_field 'author_sort asc, title_sort asc', :label => 'author'
    config.add_sort_field 'title_sort asc, pub_date_sort desc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    config.advanced_search = {
      :form_solr_parameters => {
        "facet.field" => ["access_facet", "format", "language_facet", "building_facet"],
        "facet.limit" => -1, # return all facet values
        "facet.sort" => "index" # sort by byte order of values
      }
    }
    #Add pub date for advanced search only.
    config.add_search_field("publication_date") do |field|
      field.include_in_simple_select = false
      field.solr_parameters = { :qf => "pub_date" }
    end

    # Location code for custom searches
    config.add_search_field("location_code") do |field|
      field.include_in_simple_select = true
      field.include_in_advanced_search = false
      field.solr_parameters = { :qf => "location_code_t" }
    end

    # Bookplate code for custom searches
    config.add_search_field("bookplate_code") do |field|
      field.include_in_simple_select = true
      field.include_in_advanced_search = false
      # I cannot specify qf here because I want to support regular
      # expressions. Solr supports regex via `q=bookplate_code_ss:/something.*/`
      # but not using `q=/something.*/&qf=bookplate_code_ss`.
      # Regex support is also why I am forcing eDisMax (which should be our
      # default but that's another issue)
      field.solr_parameters = { defType: "edismax" }
    end
  end  # end of `configure_blacklight do |config|`

  def ourl_service
    doc_id = params['id']
    @response, @document = get_solr_response_for_doc_id(id=doc_id)
    out = {}
    out['id'] = doc_id
    out['ourl'] = @document.export_as_openurl_ctx_kev( document_partial_name(@document) )
    render json: out
  end

  #Removes the last_easy_search session variable when a user runs a catalog search
  #
  def set_easy_search
    if params[:action] == 'index'
        session[:last_easy_search] = nil
    end
  end

  def index
    adjust_special_fields()

    if invalid_search()
      Rails.logger.info("Skipped invalid search for #{request.ip} (#{request.user_agent}): #{params.keys}")
      render text: "invalid request", status: 400
      return
    end

    @render_opensearch = true
    relax_max_per_page if api_call?
    ret_val = super
    restore_max_per_page if api_call?
    ret_val
  end

  def show
    id = params[:id] || ""
    if id.length == 9 && !id.start_with?("bdr:")
      # if the id includes the checksum digit, redirect to the
      # one without it.
      new_id = id[0..7]
      redirect_to catalog_path(id: new_id, format: params[:format]), status: 302
      return
    end

    @render_opensearch = true
    r = super
    r
  end

  # Blacklight override
  # Ability to configure when to response to OpenSearch requests
  def opensearch
    respond_to do |format|
      format.xml do
        render :layout => false
      end
      if ENV['ALLOW_OPEN_SEARCH'] == "false"
        data = {msg: 'This API has been temporarily disabled. ' +
          'Please contact the library if you are affected by this.'}
      else
        q = params[:q] || ""
        if q.length <= 3
          data = []
        else
          data = get_opensearch_response
        end
      end
      format.json do
        render :json => data
      end
    end
  end

  # Redirects user to the catalog page with the appropriate filter
  # to view items purchased witht the given bookplate code.
  def bookplate
    url = catalog_url(id:"")
    if params[:code] != nil
      code = (params[:code] || "").strip
      if code.length > 0
        # create a search URL with the indicated bookplate
        url += "?search_field=bookplate_code&q=#{code}"
        url += "&sort=pub_date_sort desc, title_sort asc"
      end
    end
    redirect_to url
  end

  # Blacklight override
  # Email Action (this will render the appropriate view on GET requests and process the form and send the email on POST requests)
  def email_action documents
    # TODO: render HTTP error status code
    return if spam_attempt?
    mail = RecordMailer.email_record(documents, {:to => params[:to], :message => params[:message]}, url_options)
    if mail.respond_to? :deliver_now
      mail.deliver_now
    else
      mail.deliver
    end
  end

  # Blacklight override
  def validate_email_params
    case
    when params[:to].blank?
      flash[:error] = I18n.t('blacklight.email.errors.to.blank')
    when !params[:to].match(defined?(Devise) ? Devise.email_regexp : /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
      flash[:error] = I18n.t('blacklight.email.errors.to.invalid', :to => params[:to])
    when spam_check? && !trusted_ip?(request.remote_ip) && params[:agreement].blank?
      flash[:error] = "Must confirm that you are not a robot, please check the checkbox"
      Rails.logger.info( "E-mail not sent, user might be a bot")
    end
    flash[:error].blank?
  end

  private

    def adjust_special_fields
      return if params[:q] == nil || params[:q].empty?

      if params[:search_field] == "bookplate_code"
        if params[:q].start_with?("bookplate_code_ss:")
          # Nothing to do - assume the value has already been processed
        else
          # Add the field to the expression and make the value a regex
          # q=bookplate_code_ss:/value/
          # Adding the field to the expression is required when using regex
          # search values in Solr.
          params[:q] = "bookplate_code_ss:#{bookplate_regex(params[:q])}"
        end
      end
    end

    def api_call?
      format = params[:format]
      return format == "xml" || format == "json"
    end

    # Returns true if the parameters in the search look bogus.
    # This is to handle the issues that we've been getting with crawlers
    # submitting invalid search parameters, like "    f" or "++++search_field".
    def invalid_search()
      params.keys.each do |key|
        if key[0] == " " || key[0] == "+"
          return true
        end
      end
      false
    end

    def relax_max_per_page
      blacklight_config.max_per_page = 1000
    end

    def restore_max_per_page
      blacklight_config.max_per_page = 100
    end

    def spam_attempt?
      return false if spam_check? == false
      return false if trusted_ip?(request.remote_ip)
      case
      when params[:t1] == nil
        Rails.logger.info( "E-mail not sent, missing token 1.")
        return true
      when params[:t2] == nil
        Rails.logger.info( "E-mail not sent, missing token 2.")
        return true
      when params[:t1] != params[:t2]
        Rails.logger.info( "E-mail not sent, request token mismatch (t1: #{params[:t1]}, t2: #{params[:t2]})")
        return true
      when params[:agreement] != daily_token()
        Rails.logger.info( "E-mail not sent, daily token mismatch (expected: #{daily_token()}, got: #{params[:agreement]})")
        return true
      when params[:to].to_s.downcase.include?("qq.com")
        Rails.logger.info( "E-mail not sent, qq.com email (#{params[:to]})")
        return true
      end
      return false
    end

    def is_regex?(code)
      return false if code == nil
      code.start_with?("/") && code.end_with?("/")
    end

    # Converts a given bookplate code to a regex that we can to send Solr
    # to retrive items with it. For example "bookplateBloomingdaleLymanG"
    # becomes "/bookplateBloomingdaleLymanG.*/"
    #
    # We use a regex so that we can execute "starts with" kind of searches.
    # For example a query for "bookplate 054106" is converted into
    # "/bookplate 054106.*/" (notice the .*) and will pick up items where
    # the bookplate code is "bookplate 054106_purchased_2005" or
    # "bookplate 054106_purchased_2012"
    def bookplate_regex(code)
      return code if is_regex?(code)
      safe_code = ""
      code.each_char do |c|
        case
          when (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") ||
            (c >= "0" && c <= "9") || c == " " || c == "_"
            safe_code += c
          when c == "+"
            safe_code += "%5C%2B"     # Regex escaped and URL encoded
          when c == "." || c == "*"
            safe_code += "%5C#{c}"    # Regex escaped, should I encode these too?
          else
            safe_code += "."
        end
      end
      regex = "/#{safe_code}.*/"
      regex
    end
end
