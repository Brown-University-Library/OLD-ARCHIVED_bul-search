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

  def record_source
    return "MIL" if self["record_source_s"] == nil
    self["record_source_s"]
  end

  def bdr_record?
    record_source == "BDR"
  end

  def millenium_record?
    record_source == "MIL"
  end

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
      if self["abstract_display"] != nil
        # get the value straight from Solr
        self["abstract_display"]
      else
        # parse the MARC data in Solr to get the abstract
        marc_abstract = marc_subfield_values('520','a')
      end
    rescue StandardError => e
      Rails.logger.error "Error parsing abstract for ID: #{self.fetch('id', nil)}, #{e.message}"
      []
    end
  end

  def online_availability
    @online_availability ||= begin
      if has_marc_data?
        online_availability_from_marc
      else
        online_availability_from_solr
      end
    rescue StandardError => e
      Rails.logger.error "Error parsing online_availability for ID: #{self.fetch('id', nil)}, #{e.message}"
      []
    end
  end

  # Fetches the item data for the bibliographic (BIB)
  # record. Notice that there could be more than one
  # item for a given BIB record.
  def item_data
    @item_data ||= begin
      values = []

      # Item data is on the 945 fields.
      marc_fields.each_with_index do |marc_field, index|
        next if marc_field.keys.first != "945"

        f_945 = marc_field["945"]
        location_code = subfield_value(f_945, "l")
        barcode = subfield_value(f_945, "i")

        bookplate_code = subfield_value(f_945, "f")

        # bookplate URL and display text are on the next 996
        i = index + 1
        while i < marc_fields.count
          if marc_fields[i].keys.first == "945"
            # ran into a new 945, no bookplate info found.
            break
          end

          if marc_fields[i].keys.first == "996"
            f_996 = marc_fields[i]["996"]
            bookplate_url = subfield_value(f_996, "u")
            bookplate_display = subfield_value(f_996, "z")
            # parsed a 996, we should be done.
            break
          end
          i += 1
        end

        item = ItemData.new(barcode)
        item.location_code = location_code
        item.bookplate_code = bookplate_code
        item.bookplate_url = bookplate_url
        item.bookplate_display = bookplate_display
        values << item
      end
      values
    rescue StandardError => e
      Rails.logger.error "Error parsing item_data for ID: #{self.fetch('id', nil)}, #{e.message}"
      []
    end
  end

  private

    # Returns the values for a MARC field.
    # For some fields this is an array of string (e.g. 001)
    # whereas for others (e.g. 015) is an array of Hash objects
    # with subfield definitions.
    def marc_field(code)
      values = []
      marc_fields.each do |marc_field|
        if marc_field.keys.first == code && marc_field[code] != nil
          values << marc_field[code]
        end
      end
      values
    end

    # Returns an array with the string values
    # for a field/subfield
    def marc_subfield_values(field_code, subfield_code)
      values = []
      fields = marc_field(field_code)
      fields.each do |field|
        field["subfields"].each do |subfield|
          if subfield.keys.first == subfield_code
            subfield.values.each do |value|
              if value != nil
                values << value.strip
              end
            end
          end
        end
      end
      values
    end

    def subfield_value(field, subfield_code)
      field["subfields"].each do |subfield|
        if subfield.keys.first == subfield_code
          # Could there be many values???
          value = subfield.values.first
          value = value.strip if value != nil
          return value
        end
      end
      nil
    end

    def has_marc_data?
      self["marc_display"] != nil
    end

    def marc_display_json
      @marc_display_json ||= JSON.parse(self["marc_display"])
    end

    def marc_fields
      marc_display_json["fields"]
    end

    def online_availability_from_solr
      urls = self['url_fulltext_display'] || []
      labels = self['url_suppl_display'] || []
      if urls.count != labels.count
        # Set all the labels to "avail online" since
        # we cannot guarantee which ones go with the URLs.
        #
        # In reality we cannot guarantee this even when
        # the counts match and we will need to handle this
        # at some point.
        labels = []
        urls.count.times do |url|
          labels << "Available online"
        end
      end
      urls.zip(labels).map do |url, label|
        OnlineAvailData.new(url, label, nil)
      end
    end

    def online_availability_from_marc
      values = []

      # Online availability info is on fields 856.
      marc_fields.each do |marc_field|
        next if marc_field.keys.first != "856"

        f_856 = marc_field["856"]
        url = subfield_value(f_856, "u")
        note = subfield_value(f_856, "z")
        materials = subfield_value(f_856, "3")

        online_avail = OnlineAvailData.new(url, note, materials)
        values << online_avail
      end
      values
    end
end
