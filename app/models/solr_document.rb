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
