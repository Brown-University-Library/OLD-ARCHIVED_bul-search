# -*- encoding : utf-8 -*-
require 'bulmarc'

class SolrDocument

  include Blacklight::Solr::Document
      # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marc_display
  extension_parameters[:marc_format_type] = :json

  field_semantics.merge!(
                         :title => "title_display",
                         :author => "author_display",
                         :language => "language_facet",
                         :format => "format"
                         )
  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)

  #Local MARC extensions
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

    #Allow for marc-in-json
    def load_marc
      case _marc_format_type.to_s
      when 'marcxml'
        records = MARC::XMLReader.new(StringIO.new( fetch(_marc_source_field) )).to_a
        return records[0]
      when 'marc21'
        return MARC::Record.new_from_marc( fetch(_marc_source_field) )
      when 'json'
        return MARC::Record.new_from_hash( JSON.parse( fetch(_marc_source_field) ) )
      else
        raise UnsupportedMarcFormatType.new("Only marcxml and marc21 are supported, this documents format is #{_marc_format_type} and the current extension parameters are #{self.class.extension_parameters.inspect}")
      end
    end

    def marc_display_field(name)
      #Return an empty array if method doesn't exist.
      begin
        to_marc.send(name)
      rescue NoMethodError
        nil
      end
    end

    def marc_subjects
      to_marc.subjects
    end

    #Can be a tag or array of tag numbers.
    def marc_tag(number)
      to_marc.by_tag(number)
    end

  end

  use_extension(BrownMarcDisplay) do |document|
    document.key?( :marc_display )
  end

end
