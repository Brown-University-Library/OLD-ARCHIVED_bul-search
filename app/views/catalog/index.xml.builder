xml.instruct!
xml.items "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  @document_list.each do |doc|
    xml.item do
      xml.link solr_document_url(doc['id'])
      xml.dc :title, doc['title_display'] if doc['title_display']
      xml.dc :creator, doc['author_display'] if doc['author_display']
      xml.dc :format, doc['format'] if doc['format']
      xml.dc :language_facet, doc['language_facet'] if doc['language_facet']
      xml.dc :score, doc['score'] if doc['score']

      if doc['pub_date']
        xml.dc :pub_date do
          doc['pub_date'].each do |date|
            xml.dc :date, date
          end
        end
      end

      if doc['published_display']
        xml.dc :published_display do
          doc['published_display'].each do |location|
            xml.dc :location, location
          end
        end
      end

    end
  end
end
