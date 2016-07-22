xml.instruct!
xml.items do
  @document_list.each do |doc|
    xml.item do
      xml.link solr_document_url(doc['id'])
      xml.title doc['title_display'] if doc['title_display']
      xml.creator doc['author_display'] if doc['author_display']
      xml.format doc['format'] if doc['format']
      xml.score doc['score'] if doc['score']

      if doc['language_facet']
        xml.languages do
          doc['language_facet'].each do |lang|
            xml.language lang
          end
        end
      end

      if doc['pub_date']
        xml.pub_dates do
          doc['pub_date'].each do |date|
            xml.date date
          end
        end
      end

      if doc['published_display']
        xml.pub_locations do
          doc['published_display'].each do |location|
            xml.location location
          end
        end
      end

    end
  end
end
