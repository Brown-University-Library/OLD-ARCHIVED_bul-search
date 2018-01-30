# -*- encoding : utf-8 -*-
require 'bulmarc'
require 'json'
require 'open-uri'
require "./app/models/string_utils.rb"
require "./app/models/table_of_contents.rb"
require "./app/models/marc_record.rb"

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

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Document::DublinCore)

  def get_availability_info
    Availability.get(ENV['AVAILABILITY_SERVICE'], self.fetch('id'))
  end

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

  def openurl_ctx_kev(format = nil, volume = nil)
    ctx_obj = OpenURL::ContextObject.new
    if format == 'book'
      ctx_obj.referent.set_format('book')
      ctx_obj.referent.set_metadata('btitle', self.fetch('title_display')) if self.key?('title_display')
      ctx_obj.referent.set_metadata('au', self.fetch('author_display')) if self.key?('author_display')
      ctx_obj.referent.set_metadata('pub', publisher_name())
      ctx_obj.referent.set_metadata('place', publisher_place())
      ctx_obj.referent.set_metadata('date', (self[:pub_date] || []).first)
      ctx_obj.referent.set_metadata('isbn', self.fetch('isbn_t').join(' ')) if self.key?('isbn_t')
      ctx_obj.referent.set_metadata('issn', self.fetch('issn_t').join(' ')) if self.key?('issn_t')
      ctx_obj.referent.set_metadata('volume', volume) if volume != nil
    elsif (format =~ /journal/i)
      ctx_obj.referent.set_format('journal')
      ctx_obj.referent.set_metadata('jtitle', self.fetch('title_display')) if self.key?('title_display')
      ctx_obj.referent.set_metadata('au', self.fetch('author_display')) if self.key?('author_display')
      ctx_obj.referent.set_metadata('isbn', self.fetch('isbn_t').join(' ')) if self.key?('isbn_t')
      ctx_obj.referent.set_metadata('issn', self.fetch('issn_t').join(' ')) if self.key?('issn_t')
      ctx_obj.referent.set_metadata('volume', volume) if volume != nil
    else
      #DC metadata about the object
      ctx_obj.referent.set_format('dc')
      ctx_obj.referent.set_metadata('format', format) unless format.nil?
      ctx_obj.referent.set_metadata('title', self.fetch('title_display')) if self.key?('title_display')
      ctx_obj.referent.set_metadata('creator', self.fetch('author_display')) if self.key?('author_display')
      # Notice that Zotero does not recognize pub/place/date for these kind of items.
      ctx_obj.referent.set_metadata('publisher', self.fetch('published_display').join(' ')) if self.key?('published_display')
      ctx_obj.referent.set_metadata('volume', volume) if volume != nil
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
    values = marc.subfield_values("945", "l")
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

  def license_agreements
    @license_agreements ||= begin
      agreements = []
      fields = marc.field("540")
      fields.each do |field, index|
        a = marc.subfield_value(field, "a")
        if a != nil
          u = marc.subfield_value(field, "u")
          agreement = {text: a, url: u}
          agreements << agreement
        end
      end
      agreements
    end
  end

  # I'd use the 830 field. It is a controlled heading for the series,
  # so it can act like any of the added author fields. There will be
   #some records that only have 490 and no 830
  def series
    @series ||= begin
      series = marc.subfield_values("830", "a").first
      if series == nil
        series = marc.subfield_values("490", "a").first
      end
      series
    end
  end

  def content_media_carrier
    @content_media_carrier ||= begin
      content = marc.subfield_values("336", "a").first
      media = marc.subfield_values("337", "a").first
      carrier = marc.subfield_values("338", "a").first
      if content != nil || media != nil || carrier != nil
        {content: content, media: media, carrier: carrier}
      else
        {}
      end
    rescue StandardError => e
      Rails.logger.error "Error parsing content_media_carrier for ID: #{self.fetch('id', nil)}, #{e.message}"
      {}
    end
  end

  def performer_notes
    @performer_notes ||= begin
      notes = marc.subfield_values("511", "a")
    rescue StandardError => e
      Rails.logger.error "Error parsing performer notes for ID: #{self.fetch('id', nil)}, #{e.message}"
      []
    end
  end

  def music_notes
    @music_notes ||= begin
      notes = []
      fields = marc.field("028")
      fields.each do |field, index|
        a = marc.subfield_value(field, "a")
        b = marc.subfield_value(field, "b")
        note = StringUtils.clean_join(a, b)
        if note != nil
          notes << note
        end
      end
      notes
    rescue StandardError => e
      Rails.logger.error "Error parsing music notes for ID: #{self.fetch('id', nil)}, #{e.message}"
      []
    end
  end

  def music_numbers
    @music_numbers ||= begin
      numbers = []
      fields = marc.field("024")
      fields.each do |field, index|
        text = marc.subfield_value(field, "a")
        if text != nil
          source = marc.subfield_value(field, "2")
          qualifying = marc.subfield_value(field, "q")
          url = nil
          if source == "doi"
            url = "https://doi.org/#{text}"
          end
          number = {text: text, source: source, url: url, qualifying: qualifying}
          numbers << number
        end
      end
      numbers
    rescue StandardError => e
      Rails.logger.error "Error parsing music number for ID: #{self.fetch('id', nil)}, #{e.message}"
      []
    end
  end


  def full_abstract
    @full_abstract ||= begin
      if self["abstract_display"] != nil
        # get the value straight from Solr
        self["abstract_display"]
      else
        # parse the MARC data in Solr to get the abstract
        marc.subfield_values('520','a')
      end
    rescue StandardError => e
      Rails.logger.error "Error parsing abstract for ID: #{self.fetch('id', nil)}, #{e.message}"
      []
    end
  end

  def publisher_name
    @publisher_name ||= begin
      value = StringUtils.strip_punctuation(marc.subfield_values('264','b').first)
      if value == nil
        value = StringUtils.strip_punctuation(marc.subfield_values('260','b').first)
      end
    rescue StandardError => e
      Rails.logger.error "Error parsing publisher_name for ID: #{self.fetch('id', nil)}, #{e.message}"
      nil
    end
  end

  def publisher_place
    @publisher_place ||= begin
      value = StringUtils.strip_punctuation(marc.subfield_values('264','a').first)
      if value == nil
        value = StringUtils.strip_punctuation(marc.subfield_values('260','a').first)
      end
    rescue StandardError => e
      Rails.logger.error "Error parsing publisher_place for ID: #{self.fetch('id', nil)}, #{e.message}"
      nil
    end
  end

  def online_availability
    @online_availability ||= begin
      if has_marc_data?
        online_availability_from_marc
      else
        # TODO: I don't think we need this. marc_data is always true.
        # Remove this after the big refactor of the recall/easyBorrow feature
        # has been finished.
        online_availability_from_solr
      end
    rescue StandardError => e
      Rails.logger.error "Error parsing online_availability for ID: #{self.fetch('id', nil)}, #{e.message}"
      []
    end
  end

  # This  method is to support the UI.
  # We only show the Availability section on the page
  # if there are physical books or if there are online books
  # that are associated with a bookplate (so that we display
  # which ones were bought with the bookplate).
  def show_item_availability?
    item_data.each do |item|
      if !item.online?
        return true
      else
        if item.bookplate_url != ""
          return true
        end
      end
    end
    false
  end

  def volume_count
    @volume_count ||= item_data.map {|item| item.volume }.uniq.count
  end

  def copy_count
    @copy_count ||= item_data.map {|item| item.copy }.uniq.count
  end

  def items_multi_type
    v_count = volume_count
    c_count = copy_count
    case
    when v_count == 0 && c_count == 0
      "none"
    when v_count == 1 && c_count == 1
      "single"
    when v_count > 1 && c_count == 1
      "volume"
    when v_count == 1 && c_count > 1
      "copy"
    else
      "both"
    end
  end

  def book_services_url
    "https://josiah.brown.edu/search~S7?/.#{id}/.#{id}/%2C1%2C1%2CB/request~#{id}"
  end

  # Fetches the item data for the bibliographic (BIB)
  # record. Notice that there could be more than one
  # item for a given BIB record.
  def item_data
    @item_data ||= begin
      marc.items()
    rescue StandardError => e
      Rails.logger.error "Error parsing item_data for ID: #{self.fetch('id', nil)}, #{e.message}\r\n#{e.backtrace}"
      []
    end
  end

  def easyBorrowUrl(volume = nil)
    bib_format = self.fetch('format', "").downcase
    open_url = openurl_ctx_kev(bib_format, volume)
    url = "https://library.brown.edu/easyaccess/find/?#{open_url}"
    url
  end

  private

    def has_marc_data?
      self["marc_display"] != nil
    end

    def marc
      @marc_record ||= MarcRecord.new(self["marc_display"])
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
      marc.fields.each do |marc_field|
        next if marc_field.keys.first != "856"

        f_856 = marc_field["856"]
        url = marc.subfield_value(f_856, "u")
        note = marc.subfield_value(f_856, "z")
        materials = marc.subfield_value(f_856, "3")

        online_avail = OnlineAvailData.new(url, note, materials)
        values << online_avail
      end
      values
    end
end
