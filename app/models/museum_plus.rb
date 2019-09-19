# Museum Plus API reference: http://docs.zetcom.com/ws/

class MuseumPlus
    def initialize(base_url, user, password)
        @base_url = base_url
        @user = user
        @password = password
    end

    def search_raw(page_size, offset)
        # For now they query is hard coded to the Haffenreffer fields:
        #   ObjPublicationStatusVoc = "99638" means status "web-only"
        #
        query = <<~END_XML_PAYLOAD
          <?xml version="1.0" encoding="UTF-8"?>
          <application xmlns="http://www.zetcom.com/ria/ws/module/search" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.zetcom.com/ria/ws/module/search http://www.zetcom.com/ria/ws/module/search/search_1_1.xsd">
            <modules>
              <module name="Object">
                <search limit="#{page_size}" offset="#{offset}">
                    <expert>
                      <and>
                        <equalsField fieldPath="ObjPublicationStatusVoc" operand="99638" />
                      </and>
                    </expert>
                    <select>
                      <field fieldPath="__id"/>
                      <field fieldPath="ObjObjectTitleTxt" />
                      <field fieldPath="ObjPublicationDimsVrt" />
                      <field fieldPath="ObjInventoryDescription0057Clb" />
                      <field fieldPath="ObjPeopleVrt" />
                      <field fieldPath="ThumbnailBoo" />
                    </select>
                </search>
              </module>
            </modules>
          </application>
        END_XML_PAYLOAD

        uri = URI.parse(@base_url + "/module/Object/search/")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(uri.request_uri)
        request.add_field("Content-Type", "application/xml")
        request.basic_auth(@user, @password)
        request.body = query
        response = http.request(request)
        response.body
    end

    def search()
      items = []
      page_size = 100
      offset = 0
      total_pages = 0
      page = 1
      while true
        xml = search_raw(page_size, offset)
        response = search_response(xml)

        if total_pages == 0
          total_pages = response[:num_found] / page_size
          total_pages += 1 if (response[:num_found] % page_size) != 0
        end

        response[:items].each do |item|
          items << item
        end
        break if items.count >= response[:num_found]
        offset += page_size

        # safe guard
        page += 1
        break if page > total_pages
      end
      items
    end

    def search_response(xml)
      results = {num_found: 0, items: []}
      doc = Nokogiri(xml)
      obj_doc = doc.search('modules//module[name="Object"]').first

      # Total number of object found
      results[:num_found] = obj_doc["totalSize"].to_i

      # Details for the objects found (paginated)
      obj_doc.search('moduleItem').each do |m_item|
        item = {
          id: id_field(m_item),
          title: data_field(m_item, "ObjObjectTitleTxt"),
          description: data_field(m_item, "ObjInventoryDescription0057Clb"),
          dimensions: virtual_field(m_item, "ObjPublicationDimsVrt"),
          people: virtual_field(m_item, "ObjPeopleVrt"),
          has_thumbnail: m_item.attributes["hasAttachments"].value == "true"
        }
        results[:items] << item
      end
      results
    end

    # Fetches the actual thumbnail image for a given ID
    def thumbnail(id)
      uri = URI.parse(@base_url + "/module/Object/#{id}/thumbnail")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(@user, @password)
      response = http.request(request)
      response.body
    end

    def id_field(doc)
      system_field(doc, "__id").to_i
    end

    def system_field(doc, name)
      doc.search('systemField[name="' + name + '"]//value').text
    end

    def data_field(doc, name)
      doc.search('dataField[name="' + name + '"]//value').text
    end

    def virtual_field(doc, name)
      doc.search('virtualField[name="' + name + '"]//value').text
    end
end