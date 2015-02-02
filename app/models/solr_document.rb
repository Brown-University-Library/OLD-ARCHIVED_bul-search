# -*- encoding : utf-8 -*-
require 'bulmarc'

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
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)

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
  end

  use_extension(BrownMarcDisplay) do |document|
    document.key?( :marc_display )
  end

end
