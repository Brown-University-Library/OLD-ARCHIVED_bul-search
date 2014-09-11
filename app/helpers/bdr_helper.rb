module BdrHelper
  require 'json'
  require 'openssl'
  require 'open-uri'

  def bdr_grab_item_api_data(doc)
    url = "#{ENV['BDR_ITEM_API_URL']}#{doc.id}/"
    response = open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
    bdr_item = JSON.parse(response.read)
  end

  ##
  # Extension point for downstream applications
  # to provide more interesting routing to
  # documents
  def bdr_url_for_document doc, options = {}
    bdr_path doc['pid']
  end

  ##
  # Link to the previous document in the current search context
  def bdr_link_to_previous_document(previous_document)
    link_opts = bdr_session_tracking_params(previous_document, search_session['counter'].to_i - 1).merge(:class => "previous", :rel => 'prev')
    link_to_unless previous_document.nil?, raw(t('views.pagination.previous')), bdr_url_for_document(previous_document), link_opts do
      content_tag :span, raw(t('views.pagination.previous')), :class => 'previous'
    end
  end

  ##
  # Link to the next document in the current search context
  def bdr_link_to_next_document(next_document)
    link_opts = bdr_session_tracking_params(next_document, search_session['counter'].to_i + 1).merge(:class => "next", :rel => 'next')
    link_to_unless next_document.nil?, raw(t('views.pagination.next')), bdr_url_for_document(next_document), link_opts do
      content_tag :span, raw(t('views.pagination.next')), :class => 'next'
    end
  end

  ##
  # Attributes for a link that gives a URL we can use to track clicks for the current search session
  # @param [SolrDocument] document
  # @param [Integer] counter
  # @example
  #   session_tracking_params(SolrDocument.new(id: 123), 7)
  #   => { data: { :'tracker-href' => '/catalog/123/track?counter=7&search_id=999' } }
  def bdr_session_tracking_params document, counter
    if document.nil?
      return {}
    end

    { :data => {:'context-href' => bdr_track_path(document['pid'], per_page: params.fetch(:per_page, search_session['per_page']), counter: counter, search_id: current_search_session.try(:id))}}
  end

end
