# -*- encoding : utf-8 -*-
class BdrSolrDocument < SolrDocument

  self.unique_key = 'pid'

  def to_partial_path
    'bdr/document'
  end
  
end
