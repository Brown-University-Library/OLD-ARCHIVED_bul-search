# -*- encoding : utf-8 -*-
require 'bulmarc'
require 'json'

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
end
