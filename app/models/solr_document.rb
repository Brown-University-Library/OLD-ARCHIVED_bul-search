# -*- encoding : utf-8 -*-
require 'bulmarc'
require 'json'
require 'open-uri'

class TableOfContents

  def initialize toc_970_display, toc_display
    if !toc_970_display.nil?
      @toc_info = JSON.parse(toc_970_display[0])
    elsif !toc_display.nil?
      @toc_info = JSON.parse(toc_display[0])
    else
      raise Exception.new('no TableOfContents info')
    end
    @chapters = make_chapters
  end

  def make_chapters
    chapters = []
    @toc_info.each do |chapter|
      ['label', 'indent', 'title', 'page'].each do |key|
        chapter[key] = "" if chapter[key].nil?
      end
      chapter['authors'] = [] if chapter['authors'].nil?
      chapters << chapter
    end
    chapters
  end

  def chapters
    @chapters
  end

end

class SolrDocument

  include MarcDisplay

  include Blacklight::Solr::Document

  extension_parameters[:marc_source_field] = :marc_display
  extension_parameters[:marc_format_type] = :json

  field_semantics.merge!(
                         :title => "title_display",
                         :author => "author_display",
                         :language => "language_facet",
                         :format => "format"
                         )
  self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Document::Email )

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Document::Sms )

  def location_data_url
    "https:#{ENV['AVAILABILITY_SERVICE']}#{self.fetch('id')}"
  end

  def make_http_call url
    begin
      resp = open(url, 'rb')
      resp.read
    rescue StandardError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  def get_availability_info
    url = location_data_url
    availability_response = make_http_call url
    return nil if (availability_response.nil? || availability_response.empty?)
    JSON.parse(availability_response)
  end

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Document::DublinCore)

  #Local overrides
  module BrownMarcDisplay
    include Blacklight::Solr::Document::Marc

    def self.extended(document)
      document.will_export_as(:xml)
      document.will_export_as(:marc, "application/marc")
      # marcxml content type:
      # http://tools.ietf.org/html/draft-denenberg-mods-etc-media-types-00
      document.will_export_as(:marcxml, "application/marcxml+xml")
      document.will_export_as(:openurl_ctx_kev, "application/x-openurl-ctx-kev")
      document.will_export_as(:endnote, "application/x-endnote-refer")
    end

    #override blacklight-marc with our own OpenURL code
    def export_as_openurl_ctx_kev(format = nil)
      self.openurl_ctx_kev(format)
    end

  end

  use_extension(BrownMarcDisplay) do |document|
    document.key?( :marc_display )
  end

  def openurl_ctx_kev(format = nil)
    ctx_obj = OpenURL::ContextObject.new
    if format == 'book'
      ctx_obj.referent.set_format('book')
      ctx_obj.referent.set_metadata('btitle', self.fetch('title_display')) if self.key?('title_display')
      ctx_obj.referent.set_metadata('au', self.fetch('author_display')) if self.key?('author_display')
      ctx_obj.referent.set_metadata('pub', self.fetch('published_display').join(' ')) if self.key?('published_display')
      ctx_obj.referent.set_metadata('isbn', self.fetch('isbn_t').join(' ')) if self.key?('isbn_t')
      ctx_obj.referent.set_metadata('issn', self.fetch('issn_t').join(' ')) if self.key?('issn_t')
    elsif (format =~ /journal/i)
      ctx_obj.referent.set_format('journal')
      ctx_obj.referent.set_metadata('jtitle', self.fetch('title_display')) if self.key?('title_display')
      ctx_obj.referent.set_metadata('au', self.fetch('author_display')) if self.key?('author_display')
      ctx_obj.referent.set_metadata('isbn', self.fetch('isbn_t').join(' ')) if self.key?('isbn_t')
      ctx_obj.referent.set_metadata('issn', self.fetch('issn_t').join(' ')) if self.key?('issn_t')
    else
      #DC metadata about the object
      ctx_obj.referent.set_format('dc')
      ctx_obj.referent.set_metadata('format', format) unless format.nil?
      ctx_obj.referent.set_metadata('title', self.fetch('title_display')) if self.key?('title_display')
      ctx_obj.referent.set_metadata('creator', self.fetch('author_display')) if self.key?('author_display')
      ctx_obj.referent.set_metadata('publisher', self.fetch('published_display').join(' ')) if self.key?('published_display')
    end
    ctx_obj.kev
  end

  def has_toc?
    self.key?('toc_display') || self.key?('toc_970_display')
  end

  def get_toc
    toc_display = self.fetch('toc_display', nil)
    toc_970_display = self.fetch('toc_970_display', nil)
    TableOfContents.new toc_970_display, toc_display
  end

  def has_uniform_titles?
    self.key?('uniform_titles_display') || self.key?('new_uniform_title_author_display')
  end

  def has_related_works?
    self.key?('uniform_related_works_display')
  end

  def get_uniform_titles
    uniform_titles = []
    if self.key?('uniform_titles_display')
      titles = JSON.parse(self['uniform_titles_display'][0])
      titles.each do |title|
        uniform_titles << title
      end
    end
    if self.key?('new_uniform_title_author_display')
      titles = JSON.parse(self['new_uniform_title_author_display'][0])
      titles.each do |title|
        title['author'] = self['author_display']
        uniform_titles << title
      end
    end
    uniform_titles
  end

  def get_related_works
    related_works = []
    if self.key?('uniform_related_works_display')
      titles = JSON.parse(self['uniform_related_works_display'][0])
      titles.each do |title|
        related_works << title
      end
    end
    related_works
  end

  def get_uniform_7xx_info
    uniform_7xx_records = []
    if self.key?('uniform_related_title_author_display')
      uniform_7xx_records = JSON.parse(self['uniform_related_title_author_display'][0])
    end
    uniform_7xx_records
  end


  # Returns an array with the string values for a field.
  def marc_field_values(field)
    values = []
    fields = marc_field(field)
    fields.each do |value|
      if value != nil
        values << value.strip
      end
    end
  end

  # Returns an array with the string values for a field/subfield
  def marc_subfield_values(field, subfield)
    values = []
    fields = marc_field(field)
    fields.each do |marc_field|
      marc_field["subfields"].each do |marc_subfield|
        if marc_subfield.keys.first == subfield
          marc_subfield.values.each do |value|
            if value != nil
              values << value.strip
            end
          end
        end
      end
    end
    values
  end

  def location_names
    # Once the location_code_t field is in Solr we shouldn't
    # need to parse it out of the marc_display value.
    locations = []
    values = marc_subfield_values("945", "l")
    values.uniq.each do |code|
      next if code == nil
      location = Location.find_by_code(code)
      if location != nil
        locations << location.name
      else
        # Must be a new location not in the database,
        # use the code.
        locations << "[#{code}]"
      end
    end
    locations
  end

  def full_abstract
    @full_abstract ||= begin
      marc_abstract = marc_subfield_values('520','a')
      if marc_abstract.count > 0
        marc_abstract
      else
        # Default to the value indexed in Solr, not sure
        # this will help, but at least it will preserve
        # the value that we used to display before.
        self['abstract_display'] || []
      end
    rescue
      Rails.logger.error "Error parsing abstract for ID: #{self.fetch('id', nil)}"
      []
    end
  end

  def item_data
    @item_data ||= begin
      values = []
      fields = marc_field('945')
      fields.each do |marc_field|
        item = ItemData.new
        marc_field["subfields"].each do |marc_subfield|
          if marc_subfield.keys.first == 'i'
            item.barcode = marc_subfield.values.first
          end
          if marc_subfield.keys.first == 'f'
            item.bookplate_code = marc_subfield.values.first
          end
          if marc_subfield.keys.first == 'l'
            item.location_code = marc_subfield.values.first
          end
        end
        if item.has_data?
          values << item
        end
      end
      values
    rescue
      Rails.logger.error "Error parsing item_data for ID: #{self.fetch('id', nil)}"
      []
    end
  end

  private

    # Returns the values for a MARC field.
    # For some fields this is an array of string (e.g. 001)
    # whereas for others (e.g. 015) is an array of Hash objects
    # with subfield definitions.
    def marc_field(field)
      values = []
      marc_display_json["fields"].each do |marc_field|
        if marc_field.keys.first == field && marc_field[field] != nil
          values << marc_field[field]
        end
      end
      values
    end

    def marc_display_json
      @marc_display_json ||= JSON.parse(self["marc_display"])
    end
end
