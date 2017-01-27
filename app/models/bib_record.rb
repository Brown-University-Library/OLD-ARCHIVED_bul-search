require "./lib/http_json.rb"

# BRD API links
# https://repository.library.brown.edu/studio/item/bdr%3A297551/?format=json
# https://repository.library.brown.edu/api/search/?q=ir_collection_name:Dissertations&rows=20

class BibRecord
  attr_accessor :id, :updated_dt, :oclc, :title_t, :title_display,
    :opensearch_display, :author_display, :author_addl_display,
    :author_t, :author_addl_t, :physical_display, :pub_date, :pub_date_sort,
    :online_b, :format, :language_facet, :location_code_t, :subject_t,
    :marc_display, :abstract_display,
    :url_fulltext_display, :url_suppl_display,
    :topic_facet,
    :record_source_s,
    :bdr_notes_display
  attr_reader :timestamp

  def initialize
    @id = nil
    @updated_dt = nil
    @oclc = []
    @title_t = []
    @title_display = nil
    @opensearch_display = []
    @author_display = nil
    @author_addl_display = []
    @author_t = []
    @author_addl_t = []
    @physical_display = []
    @pub_date = []
    @pub_date_sort = 0
    @online_b = false
    @format = nil
    @language_facet = []
    @location_code_t = []
    @subject_t = []
    @marc_display = nil
    @timestamp = nil
    @abstract_display = ""
    @topic_facet = []
    @record_source_s = ""
    @bdr_notes_display = []
  end

  def save
    BibRecord.save_batch([self])
  end

  def to_s
    "#{@id}, #{@title_display}"
  end

  def self.save_batch(bib_records)
    solr = SolrLite::Solr.new(ENV["SOLR_URL"])
    response = solr.update(bib_records.to_json)
    response.ok?
  end
end
