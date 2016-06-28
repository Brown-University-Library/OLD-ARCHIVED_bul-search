xml.instruct!
xml.items "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  @document_list.each do |doc|
    xml.item do
      xml.link solr_document_url(doc['id'])
      xml.dc :title, doc['title_display'] if doc['title_display']
      xml.dc :creator, doc['author_display'] if doc['author_display']
      xml.dc :format, doc['format'] if doc['format']

      call_numbers = doc['lc_callnum_display'] || []
      if call_numbers.count > 0
        xml.call_numbers do
          call_numbers.each do |call_number|
            xml.number call_number
          end
        end
      end

      # location?
    end
  end
end
