# -*- encoding : utf-8 -*-
class BdrSolrDocument < SolrDocument

  self.unique_key = 'pid'

  def to_partial_path
    'bdr/document'
  end
  
  # Email uses the semantic field mappings below to generate the body of an email.
  BdrSolrDocument.use_extension( Blacklight::Solr::Document::Email )

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  BdrSolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  field_semantics.merge!(    
                         :title => "primary_title",
                         :author => "contributor_display",
                         :format => "object_type"
                         )
end
