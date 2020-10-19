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

    # Switching from pub_date (string) to pub_date_sort (int) so that the range
    # is calculated properly. Having a field marked as `:range => true` is what causes
    # Blacklight to request it as in the stats from Solr (via `stats.field=field_name`)
    #
    # See send_and_receive() in /Users/hectorcorrea/.gem/ruby/2.3.5/gems/blacklight-5.19.2/lib/blacklight/solr/repository.rb
    # for an example.
    #
    # The field used as range must be numeric so that the min/max stats are calculated
    # correctly. When the field is a string field the values are min="1000" and max="987"
    # which is wrong and also causes Ruby to throw error:
    #
    #     Math::DomainError - Numerical argument is out of domain - "log10":
    #
    # somewhere along the way when it tries to calculate a range for the publication date
    # slider based on these incorrect min/max values.
    #
    config.add_facet_field 'pub_date_sort', :label => 'Publication Year', :range => true

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

    config.add_search_field 'all_fields' do |field|
      field.solr_parameters = {
        defType: "dismax",
        df: "id"  # == SOLR-7-MIGRATION == Needed in Solr 7 because the server is set to Lucene
      }
      field.label = 'All Fields'
    end

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
      #
      # == SOLR-7-MIGRATION ==
      # In Solr 7 the server will default to Lucene so that we can use Local Parameters
      # and therefore we set it to DisMax via the `type` Local Parameter.
      # Notice that setting it via `defType` in the query string does NOT work
      # for Local Parameters.
      field.solr_local_parameters = {
        :type => 'dismax',
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end

    config.add_search_field('author') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = {
        :type => 'dismax',
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
        :type => 'dismax',
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

    config.add_search_field('series') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'title_series_t' }
      field.qt = 'search'
      field.solr_local_parameters = {
        :type => 'dismax',
        :qf => 'title_series_t',
        :pf => 'title_series_t'
      }
    end

    # "sort results by" select (pulldown)
    # Make sure to white-list in clean_sort_value() any field added here
    config.add_sort_field 'score desc, pub_date_sort desc, title_sort asc', :label => 'relevance'
    config.add_sort_field 'pub_date_sort desc, title_sort asc', :label => 'year (most recent first)'
    config.add_sort_field 'pub_date_sort asc, title_sort asc', :label => 'year (oldest first)'
    config.add_sort_field 'author_sort asc, title_sort asc', :label => 'author'
    config.add_sort_field 'title_sort asc, pub_date_sort desc', :label => 'title'
    config.add_sort_field 'callnumber_norm_ss asc', :label => 'call number'

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
      field.solr_parameters = { :qf => "pub_date", defType: "dismax" }
    end

    # Location code for custom searches
    config.add_search_field("location_code") do |field|
      field.include_in_simple_select = true
      field.include_in_advanced_search = false
      field.solr_parameters = { :qf => "location_code_t", defType: "dismax" }
    end

    # Bookplate code for custom searches
    # See also adjust_special_fields() below.
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

    config.add_search_field("call_number") do |field|
      field.include_in_simple_select = true
      field.include_in_advanced_search = false
      field.solr_parameters = {qf: "callnumber_ss", defType: "edismax"}
    end

    config.add_search_field("call_number_range") do |field|
      field.include_in_simple_select = true
      field.include_in_advanced_search = false
      field.solr_parameters = {qf: "callnumber_norm_ss", defType: "edismax"}
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

  def callnumber_search()
    @new_header = use_new_header()
    @altered_search_terms = false
    @new_q = ""
    original_q = params[:q] || ""
    searcher = SearchCustom.new(blacklight_config)
    @response, @document_list, match = searcher.callnumber(original_q, params)
    if @response.documents.count == 0
      Rails.logger.info("Call number search failed: #{original_q}")
    else
      if match == original_q
        Rails.logger.info("Call number search success: #{original_q}")
      else
        @altered_search_terms = true
        @new_q = match
        Rails.logger.info("Call number search success on retry: #{match} (#{original_q})")
      end
    end

    if @response.documents.count == 0 && params[:q] != nil
      if params[:q].strip.ends_with?("*")
        search_url = catalog_index_url(q: params[:q], search_field: nil)
        @retry_option = "You are limiting your search by <b>Call Number</b>. " +
          "Try again using <a href=#{search_url}>All Fields</a>."
      else
        search_url = catalog_index_url(q: params[:q].strip + "*", search_field: "call_number")
        @retry_option = "Try again using <a href=\"#{search_url}\">wildcard call number search</a>."
      end
    end
    render "index"
  end

  def index
    @show_search_fields = true
    @new_header = use_new_header()
    @is_covid = (ENV["COVID"] == "true")
    @is_pod = (params["pod"] == "true")

    @trusted_ip = trusted_ip?(request.remote_ip)

    if @is_pod && false
      pod = SearchPod.new(ENV["SOLR_URL"])
      results = pod.search_web(params, true)
      @response = Blacklight::Solr::Response.new(results.solr_response, nil)
      @document_list = @response.documents
      Rails.logger.info("=================> Using POD logic")
      return
    end

    if params["search_field"] == nil
      # == SOLR-7-MIGRATION
      # Need it to make sure the facets for an empty search work
      # otherwise we get an empty list of facets.
      #
      # TODO: The problem with this hack is that it's executing the
      # search (with no "q") and showing a random list of search results.
      params["search_field"] = "all_fields"
    end

    params["sort"] = clean_sort_value(params["sort"])

    # This is needed to prevent turbolinks from re-displaying a previous error message
    # on the request following a bad request from the same user. This issue only happens
    # in production (!).
    flash[:error] = nil

    @warn_cjk = false
    @cjk_search = is_cjk_search?(params)
    if @cjk_search
      @warn_cjk = switch_to_cjk_search(params)
      if @warn_cjk
        Rails.logger.info( "CJK search by (#{params[:search_field]})")
      else
        Rails.logger.info( "CJK search skipped")
      end
    end

    @altered_search_terms = false
    @new_q = ""
    @retry_option = nil

    if invalid_search()
      # Stop the request.
      Rails.logger.info("Skipped invalid search for #{request.ip} (#{request.user_agent}). Params: #{params}")
      render text: "invalid request", status: 400
      return
    end

    if invalid_page()
      if params["format"] && params["format"] != "html"
        # Most likely a crawler. Stop the request.
        Rails.logger.info("Skipped invalid page for crawler #{request.ip} (#{request.user_agent}). Params: #{params}")
        render text: "invalid request", status: 400
        return
      end

      # Most likely a human. Reset the request to page 1 and give an error
      # message to the user.
      Rails.logger.info("Skipped invalid page for human #{request.ip} (#{request.user_agent}). Params: #{params}")
      page_no = params["page"]
      flash[:error] = "The page number that you requested (#{page_no}) exceeds the " +
        "allowed limit, try limiting your search via the facets instead. " +
        "If you need to access very large page numbers please contact us via the " +
        "Feedback form."
      params["page"] = 1
    end

    if callnumber_search?
      callnumber_search()
      return
    end

    adjust_special_fields()
    @render_opensearch = true
    relax_max_per_page if api_call?
    ret_val = super
    restore_max_per_page if api_call?

    if @response.documents.count == 0 && params[:q] != nil
      is_allfields = params[:search_field] == nil || params[:search_field] == "all_fields"
      if is_allfields
        search_url = catalog_index_url(q: params[:q], search_field: "call_number")
        @retry_option = "If you are searching for a call number, try again using the <a href=\"#{search_url}\">call number search</a>."
      else
        field_info = search_field_list.find{|f| f.key == params[:search_field]}
        if field_info
          search_url = catalog_index_url(q: params[:q], search_field: nil)
          @retry_option = "You are limiting your search by <b>#{field_info.label}</b>. " +
            "Try again using <a href=#{search_url}>All Fields</a>."
        end
      end
    end

    ret_val
  rescue => ex
    Rails.logger.error("Error on search. Params: #{params}. Exception: #{ex}")
    render "error", status: 500
  end

  def show
    @new_header = use_new_header()
    @is_covid = (ENV["COVID"] == "true")
    @is_reopening = Date.today.to_s >= (ENV["REOPENING_DATE"] || "9999-01-01")

    id = params[:id] || ""
    if id.length == 9 && !id.start_with?("bdr:") && !id.start_with?("MP_HAF_")
      # if the id includes the checksum digit, redirect to the
      # one without it.
      new_id = id[0..7]
      redirect_to catalog_path(id: new_id, format: params[:format]), status: 302
      return
    end

    @render_opensearch = true
    r = super

    if @document.millenium_record?
      @classic_bib = id
    else
      # A record that does not exist in Classic Josiah
      # (e.g. one coming from the BDR)
    end

    r
  rescue Blacklight::Exceptions::RecordNotFound => exception
    Rails.logger.info("Item not found: #{id}")
    render "not_found", status: 404
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
          # == SOLR-7-MIGRATION == Needed in Solr 7 because the server is set to Lucene
          field = text
          extra = {df: "id"}
          data = get_opensearch_response(field, params, extra)
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

    def clean_sort_value(value)
      return nil if value == nil
      case
      when value == "score desc, pub_date_sort desc, title_sort asc"
        # relevance
        return value
      when value == "pub_date_sort desc, title_sort asc"
        # year (most recent first)
        return value
      when value == "pub_date_sort asc, title_sort asc"
        # year (oldest first)
        return value
      when value == "author_sort asc, title_sort asc"
        # author
        return value
      when value == "title_sort asc, pub_date_sort desc"
        # title
        return value
      when value == "callnumber_norm_ss asc"
        # call number
        return value
      end
      # Should we skip these requests altogether?
      Rails.logger.info("Ignored invalid sort value: #{value}")
      return nil
    end

    # Returns true if the parameters in the search look bogus. This is to handle
    # issues that we've been experiencing when crawlers submit requests that
    # include invalid search parameters like "    f" or "++++search_field".
    def invalid_search()
      params.keys.each do |key|
        if key[0] == " " || key[0] == "+"
          return true
        end
      end
      false
    end

    # Don't allow users to navigate past page number 1,000. Reaching that far causes
    # a lot of stress on Solr and most likely no human user will request this.
    # Most of the requests that meet this criteria (e.g. page = 405698) have been
    # from crawlers.
    def invalid_page()
      if params["page"] && params["page"].to_i > 1000
        return true
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

    def is_cjk_search?(params)
      if ENV["CJK"] != "true"
        return false
      end

      search_field = params[:search_field] || "all_fields"
      if (search_field == "all_fields" || search_field == "title" || search_field == "author")
        return StringUtils.cjk?(params[:q])
      end
      return false
    end

    def switch_to_cjk_search(params)
      if params[:cjk] == "false"
        # Nothing to do, user explicitly requested no CJK logic
        return false
      end

      case (params[:search_field] || "all_fields")
      when "all_fields"
        search_field = blacklight_config[:search_fields]["all_fields"]
        search_field.solr_parameters[:defType] = 'lucene'
        search_field.solr_local_parameters = {
          type: "edismax",
          :qf => 'title_txt_cjk author_txt_cjk',
          :pf => 'title_txt_cjk author_txt_cjk'
        }
        return true
      when "title"
        search_field = blacklight_config[:search_fields]["title"]
        search_field.solr_local_parameters = {
          type: "edismax",
          :qf => 'title_txt_cjk',
          :pf => 'title_txt_cjk'
        }
        return true
      when "author"
        search_field = blacklight_config[:search_fields]["author"]
        search_field.solr_local_parameters = {
          type: "edismax",
          :qf => 'author_txt_cjk',
          :pf => 'author_txt_cjk'
        }
        return true
      end

      # nothing to do
      return false
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
      return code if StringUtils.is_solr_regex?(code)
      safe_code = StringUtils.solr_safe_regex(code)
      regex = "/#{safe_code}.*/"
      regex
    end

    def callnumber_search?
      if params[:search_field] == "call_number" || params[:search_field] == "call_number_range"
        return true
      end
      false
    end
end
