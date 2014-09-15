class BookmarkController
  def index
    @bookmarks = token_or_current_or_guest_user.bookmarks
    bookmark_ids = @bookmarks.collect { |b| b.document_id.to_s unless b.doc_type == 'bdr' }
    bdr_bookmark_ids = @bookmarks.collect { |b| b.document_id.to_s if b.doc_type == 'bdr' }
    Rails.logger.debug("bdr_bookmark_ids: #{@bdr_bookmark_ids}")
  
    @response, @document_list = get_solr_response_for_document_ids(bookmark_ids)
    #set solr to BDR instance while we do this query, then set it to nil so it'll be reset
    @solr = bdr_blacklight_solr
    @bdr_response, @bdr_document_list = get_solr_response_for_document_ids(bdr_bookmark_ids)
    @solr = nil
    Rails.logger.debug("@bdr_document_list: #{@bdr_document_list}")

    respond_to do |format|
      format.html { } 
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
      format.json do
        render json: render_search_results_as_json
      end 

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  def bdr_blacklight_solr
    RSolr.connect(bdr_blacklight_solr_config)
  end

  def bdr_blacklight_solr_config
    {url: ENV['BDR_SOLR_URL']}
  end
end
