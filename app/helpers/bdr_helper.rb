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
