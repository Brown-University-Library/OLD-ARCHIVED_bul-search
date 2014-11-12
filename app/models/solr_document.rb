# -*- encoding : utf-8 -*-
require 'marc'

class SolrDocument

  include Blacklight::Solr::Document
      # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marc_display
  extension_parameters[:marc_format_type] = :json
  use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marc_display  )
  end

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
  module BulMarc
    include Blacklight::Solr::Document::Marc

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

    def marc_subjects
      subjs = []
      to_marc.find_all {|f| ('600'..'699') === f.tag}.each do |field|
        txt = []
        field.each do |sub_field|
          txt << sub_field.value
        end
        subjs << "#{txt.join(" -- ")}"
      end
      return subjs
    end

  end

  use_extension(BulMarc) do |document|
    document.key?( :marc_display )
  end

end
