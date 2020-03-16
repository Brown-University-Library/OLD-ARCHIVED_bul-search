require "./lib/http_json.rb"

# BibRecord represents a "bibliographic record" in Solr.
#
# Although records in Solr are ingested via Traject outside of this codebase
# we use this class to import records that are not necessarily about bibliographic
# data (like ETDs or Museum items).
class BibRecord
  attr_accessor :id, :updated_dt, :oclc, :title_t, :title_display,
    :opensearch_display,
    :author_addl_display,
    :author_addl_t,
    # :author_addl_unsteam_search,
    :author_display, # single value
    :author_facet,
    :author_spell,
    :author_t,
    # :author_unsteam_search,
    :author_vern_display,               # single value
    :new_uniform_title_author_display, # single value
    :physical_display, :pub_date, :pub_date_sort,
    :format, :language_facet, :location_code_t, :subject_t,
    :online_b, :access_facet,
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
    @author_addl_display = ""
    @author_addl_t = []
    # @author_addl_unsteam_search = []
    @author_display = ""
    @author_facet = []
    @author_spell = []
    @author_t = []
    # @author_unsteam_search = []
    @author_vern_display = ""
    @new_uniform_title_author_display = ""
    @physical_display = []
    @pub_date = []
    @pub_date_sort = nil
    @online_b = false
    @access_facet = nil
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
    solr = SolrLite::Solr.new(ENV["SOLR_URL_WRITE"])
    response = solr.update(bib_records.to_json)
    if !response.ok?
      puts response.error_msg
    end
    response.ok?
  end
end
