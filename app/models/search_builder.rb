require "./lib/user_input.rb"

class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  def initialize(processor_chain, this)
    @location_code = nil
    @callnumber = nil
    processor = setup_custom_search(processor_chain, this)
    processor_chain += [processor] if processor
    super(processor_chain, this)
  end

  def setup_custom_search(processor_chain, this)
    return if this.class != CatalogController
    if this.params[:location_code]
      @location_code = UserInput::Cleaner.clean(this.params[:location_code])
      return :search_by_location_code
    end
    if this.params[:browse_shelve_for]
      @callnumber = UserInput::Cleaner.clean(this.params[:browse_shelve_for])
      return :search_by_callnumber
    end
  end

  def search_by_callnumber(solr_parameters)
    search_token = Callnumber.new(@callnumber).lc_subclass
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "callnumber_t:#{search_token}*"
    solr_parameters[:fl] ||= []
    solr_parameters[:fl] << "id"
    solr_parameters[:fl] << "callnumber_t"
    solr_parameters[:fl] << "title_display"
    solr_parameters[:fl] << "author_display"
  end

  def search_by_location_code(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "location_code_t:#{@location_code}"
  end
end
